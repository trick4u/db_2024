import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:tushar_db/app_routes.dart';

import '../services/app_theme.dart';
import '../services/scale_util.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(
      Duration(seconds: 3),
    ); // Adjust duration as needed
    Get.offNamed(AppRoutes.AUTHWRAPPER);
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Get.put(AppTheme());
    appTheme.updateStatusBarColorSplash();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 100, 176, 238),
              Colors.deepPurpleAccent
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideInDown(
                child: Icon(
                  Icons.dashboard,
                  size: ScaleUtil.height(100),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ScaleUtil.height(20)),
              FadeIn(
                child: Text(
                  'goalKeep',
                  style: TextStyle(
                    fontFamily: GoogleFonts.shantellSans().fontFamily,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
