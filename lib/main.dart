import 'dart:ui';
import 'package:currency_detection/yoloImage.dart';
import 'package:currency_detection/yoloVideo.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'app_color.dart';


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
    flutterTts.speak("Welcome to Currency detection app");
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
            label: 'Pick Image',
            labelStyle:
            const TextStyle(fontSize: 18.0, color: AppColors.colorApp2),
            onTap: () {
              setState(() {
                option = Options.image;
              });
              //Future.delayed(const Duration(seconds: 1)).then((_) {
               // flutterTts.speak("Pick Image is ready now ");
              //});
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
                    Future.delayed(const Duration(seconds: 1)).then((_) {
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
                    Future.delayed(const Duration(seconds: 3)).then((_) {
                      flutterTts.speak("Please press to side button to can take image ");
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


