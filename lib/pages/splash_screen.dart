import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_fonts/google_fonts.dart';


import '../controller/splash_controller.dart';

class SplashScreen extends GetWidget<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SlideInUp(
            child: Hero(
              tag: 'logo',
              child: Text(
                'doBoard',
                style: TextStyle(
                  fontFamily: GoogleFonts.inder().fontFamily,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                  inherit: false,
                ),
              ),
            ),
          ),
        ));
  }
}
