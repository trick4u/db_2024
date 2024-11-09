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
    // Ensure navigation happens after widget is fully mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Use a more reliable way to delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Check if the widget is still mounted before navigating
      if (mounted) {
        await Get.offNamed(AppRoutes.AUTHWRAPPER);
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Implement proper error handling here
      if (mounted) {
        Get.offNamed(AppRoutes.AUTHWRAPPER);
      }
    }
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