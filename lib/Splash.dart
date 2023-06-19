import 'dart:async';



import 'package:currency_detection/Home.dart';
import 'package:currency_detection/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
        const Duration(seconds: 5),
            () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Home()), (route) => false));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.024;
    return Scaffold(
        backgroundColor: AppColors.colorApp1,
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: AppColors.colorApp2,
              statusBarIconBrightness: Brightness.dark),
          backgroundColor: AppColors.colorApp1,
          elevation: 0,
        ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            //image: AssetImage("assets/images/bemyeye.svg"),
            image: AssetImage("assets/images/bemyeye.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Your other widgets here
          ],
        ),
      ),
        /*body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/bemyeye.svg',
                  color: AppColors.colorApp2,
                  width: width*40,
                ),
              ]),
        )*/
    );
  }
}
