import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'app_color.dart';
import 'main.dart';

class YoloImage extends StatefulWidget {
  const YoloImage({Key? key}) : super(key: key);

  @override
  State<YoloImage> createState() => _YoloImageState();
}

class _YoloImageState extends State<YoloImage> {
  late FlutterVision vision;
  late List<Map<String, dynamic>> yoloResults;
  File? imageFile;
  int imageHeight = 1;
  int imageWidth = 1;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    loadYoloModel().then((value) {
      setState(() {
        yoloResults = [];
        isLoaded = true;
      });
    });
    pickImage(); // call this function when call YoloImage
  }

  @override
  void dispose() async {
    super.dispose();
    await vision.closeYoloModel();
  }

  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }


    return Stack(
      fit: StackFit.expand,
      children: [
        imageFile != null ? Image.file(imageFile!) : const SizedBox(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: size.width, // Set the width to the screen width
            height: 138.0, // Set the height to 138.0 pixels
            decoration: BoxDecoration(
              color: AppColors.colorApp3, // Set the background color to a custom color
              borderRadius: BorderRadius.circular(40.0), // Set the border radius to 30.0
            ),
            child: GestureDetector(
              onTap: yoloOnImage,
              onDoubleTap: pickImage,
              child: const Center(
                child: Text(
                  "One Tab You Can Detect this Objects Again \nDouble Tap You Can Detect Another Object ",  // Set the text to "Detect Objects"
                  style: TextStyle(
                    color: Colors.white, // Set the text color to white
                    fontSize: 10.0, // Set the font size to 10.0
                    height: 5.5, // Set the line height to 1.5 times the font size
                    // Set the font weight to bold
                  ),
                ),
              ),
            ),
          ),
        ),
        ...displayBoxesAroundRecognizedObjects(size),
      ],
    );
  }

  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
        labels: 'assets/labels.txt',
        modelPath: 'assets/large_epoch_float32.tflite',
        modelVersion: "yolov8",
        numThreads: 1,
        useGpu: false);
    setState(() {
      isLoaded = true;
    });
  }

  Future<void> pickImage() async {
    flutterTts.speak("now You can take image");
    Future.delayed(const Duration(seconds: 3)).then((_) {
      flutterTts.speak("Please press to side button to can take image ");
    });
    final ImagePicker picker = ImagePicker();
    // Capture a photo
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        imageFile = File(photo.path);
        Future.delayed(const Duration(seconds: 0)).then((_) {
          yoloOnImage();
          //flutterTts.speak("Image is ready now to detect ");
        });
      });
    }
  }

  yoloOnImage() async {
    yoloResults.clear();
    Uint8List byte = await imageFile!.readAsBytes();
    final image = await decodeImageFromList(byte);
    imageHeight = image.height;
    imageWidth = image.width;
    final result = await vision.yoloOnImage(
        bytesList: byte,
        imageHeight: image.height,
        imageWidth: image.width,
        iouThreshold: 0.8,
        confThreshold: 0.4,
        classThreshold: 0.5);
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
      int count = result.length;
      String numofobjects = "'you have $count objects'";
      await flutterTts.speak(numofobjects);
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        String allresult = "";
        for (var i = 0; i < result.length; i++) {
          allresult += "'I see a ${result[i]["tag"]}' ";
        }
        await flutterTts.speak(allresult);
      });
      Future.delayed(const Duration(seconds: 8)).then((_) async {
        await flutterTts.setSpeechRate(0.3); // Set the speech rate to 0.8 to slow down the speech
        await flutterTts.speak(
            "if you want hear result again please Click on the bottom of the page one click"
                "  if you want detect another objects please Click on the bottom of the page double click ");
      });
    }
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return[];

    double factorX = screen.width / (imageWidth);
    double imgRatio = imageWidth / imageHeight;
    double newWidth = imageWidth * factorX;
    double newHeight = newWidth / imgRatio;
    double factorY = newHeight / (imageHeight);

    double pady = (screen.height - newHeight) / 2;

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);
    return yoloResults.map((result) {
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY + pady,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }
}