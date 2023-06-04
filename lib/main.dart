import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'app_color.dart';
//import 'package:flutter_svg/flutter_svg.dart';

enum Options { none, image, frame, vision }

FlutterTts flutterTts = FlutterTts();

late List<CameraDescription> cameras;
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  runApp(
    const MaterialApp(
      title: 'Currency Detection App',
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Options option = Options.none;
  bool _isCameraIconPressed = true;
  @override
  void initState() {
    super.initState();
    initTts();
  }

  Future<void> initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorApp1,
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Currency Detection App',
            style: TextStyle(color: AppColors.colorApp1),
          ),
        ),
        backgroundColor: AppColors.colorApp2,
        elevation: 0,
      ),
      body: task(option),
      floatingActionButton: SpeedDial(
        //margin bottom
        icon: Icons.menu, //icon on Floating action button
        activeIcon: Icons.close, //icon when menu is expanded on button
        backgroundColor: AppColors.colorApp2, //background color of button
        foregroundColor: AppColors.colorApp1, //font color, icon color in button
        activeBackgroundColor:
        AppColors.colorApp3, //background color when menu is expanded
        activeForegroundColor: Colors.white,
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        buttonSize: const Size(56.0, 56.0),
        children: [
          SpeedDialChild(
            //speed dial child
            child: const Icon(Icons.video_call),
            backgroundColor: AppColors.colorApp4,
            foregroundColor: Colors.white,
            label: 'Live Camera',
            labelStyle:
            const TextStyle(fontSize: 18.0, color: AppColors.colorApp2),
            onTap: () {
              setState(() {
                option = Options.frame;
              });
              Future.delayed(const Duration(seconds: 1)).then((_) {
                flutterTts.speak("live camera is ready now ");
              });
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.camera),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'Upload Image',
            labelStyle:
            const TextStyle(fontSize: 18.0, color: AppColors.colorApp2),
            onTap: () {
              setState(() {
                option = Options.image;
              });
              Future.delayed(const Duration(seconds: 1)).then((_) {
                flutterTts.speak("Upload Image is ready now ");
              });
            },
          ),

        ],
      ),
    );
  }

  Widget task(Options option) {
    if (option == Options.frame) {
      return const YoloVideo();
    }
    if (option == Options.image) {
      return const YoloImage();
    }
    flutterTts.speak("Welcome to Currency detection app");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: IconButton(
                  icon: Icon(
                    Icons.video_library,
                    size: 200.0,
                    color: _isCameraIconPressed ? Colors.red : AppColors.colorApp3,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const YoloVideo(),
                        )
                    );
                    setState(() {
                      _isCameraIconPressed = true;
                    });
                    Future.delayed(const Duration(seconds: 2)).then((_) {
                      flutterTts.speak("live camera is ready now");
                    });
                  },
                ),
              ),
              Text(
                'Live Camera',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          SizedBox(height: 20),
          Column(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    size: 200.0,
                    color: _isCameraIconPressed ? AppColors.colorApp3 : Colors.red,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const YoloImage(),
                        ));
                    Future.delayed(const Duration(seconds: 2)).then((_) {
                      flutterTts.speak("Take image is ready now");
                    });
                    setState(() {
                      _isCameraIconPressed = false;
                    });
                  },
                ),
              ),
              Text(
                'Use Camera To Take Image',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class YoloVideo extends StatefulWidget {
  const YoloVideo({Key? key}) : super(key: key);

  @override
  State<YoloVideo> createState() => _YoloVideoState();
}

class _YoloVideoState extends State<YoloVideo> {
  late CameraController controller;
  late FlutterVision vision;
  late List<Map<String, dynamic>> yoloResults;
  CameraImage? cameraImage;
  bool isLoaded = false;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    init();
    initTts();
    //speak("Welcome to the app");
  }

  Future<void> initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.awaitSpeakCompletion(true);
    flutterTts.stop();
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  init() async {
    cameras = await availableCameras();
    vision = FlutterVision();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    controller.initialize().then((value) {
      loadYoloModel().then((value) {
        setState(() {
          isLoaded = true;
          isDetecting = false;
          yoloResults = [];
        });
      });
    });
  }

  @override
  void dispose() async {
    super.dispose();
    controller.dispose();
    await vision.closeYoloModel();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Camera'),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(
                controller,
              ),
            ),
            ...displayBoxesAroundRecognizedObjects(size),
            Positioned(
              bottom: 75,
              width: MediaQuery.of(context).size.width,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 5, color: Colors.white, style: BorderStyle.solid),
                ),
                child: isDetecting
                    ? IconButton(
                  onPressed: () async {
                    stopDetection();
                  },
                  icon: const Icon(
                    Icons.stop,
                    color: Colors.red,
                  ),
                  iconSize: 50,
                )
                    : IconButton(
                  onPressed: () async {
                    await startDetection();
                    await speak("Now you can detect currency");
                  },
                  icon: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                  iconSize: 50,
                ),
              ),
            ),
          ],
        ),
      ),
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

  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await vision.yoloOnFrame(
        bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        iouThreshold: 0.4,
        confThreshold: 0.4,
        classThreshold: 0.5);
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });

      await speak('I see a ${result[0]["tag"]}');
      await flutterTts.setSilence(3);
      await flutterTts.awaitSpeakCompletion(true);
      flutterTts.stop();


    }
  }

  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
    });
    if (controller.value.isStreamingImages) {
      return;
    }
    await controller.startImageStream((image) async {
      if (isDetecting) {
        cameraImage = image;
        yoloOnFrame(image);
      }
    });
    //await speak("Detection started");
    await speak("Now you can detect currency");
    await flutterTts.setSilence(5);
    stopDetection();
  }

  Future<void> stopDetection() async {
    setState(() {
      isDetecting = false;
      yoloResults.clear();
    });
    await speak("Stop Detection");
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];
    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return yoloResults.map((result) {
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY,
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
    pickImage();
  }

  @override
  void dispose() async {
    super.dispose();
    await vision.closeYoloModel();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Loading..."),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        imageFile != null ? Image.file(imageFile!) : const SizedBox(),
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
    final ImagePicker picker = ImagePicker();
    // Capture a photo
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        imageFile = File(photo.path);
        Future.delayed(const Duration(seconds: 3)).then((_) {
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
      String textToSpeak = "'I see a ${result[0]["tag"]}'";
      await flutterTts.speak(textToSpeak);
    }
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];

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
