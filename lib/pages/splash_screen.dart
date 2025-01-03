import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:tushar_db/app_routes.dart';

import '../controller/network_controller.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;
  bool _isNavigating = false;
  final _minimumSplashDuration = const Duration(seconds: 2);
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

Future<void> _initializeApp() async {
   await _navigateToNextScreen(true);
  if (_isNavigating) return;
  _isNavigating = true;

  try {
    // Shorter timeout since we're assuming online by default
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _handleTimeout();
      }
    });

    // final networkController = Get.find<NetworkController>();
    // await networkController.checkInitialConnection();

    // Ensure minimum splash duration
    final elapsedTime = DateTime.now().difference(_startTime!);
    if (elapsedTime < _minimumSplashDuration) {
      await Future.delayed(_minimumSplashDuration - elapsedTime);
    }

    if (!mounted) return;

    _navigationTimer?.cancel();
    await _navigateToNextScreen(true); // Always navigate as online initially
    
  } catch (e) {
    debugPrint('Splash screen initialization error: $e');
    if (mounted) {
      _handleTimeout();
    }
  }
}

  Future<void> _navigateToNextScreen(bool isOnline) async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      final route = isOnline ? AppRoutes.AUTHWRAPPER : AppRoutes.NETWORK;
      await Get.offNamed(route);
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Retry navigation once
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        final route = isOnline ? AppRoutes.AUTHWRAPPER : AppRoutes.NETWORK;
        await Get.offNamed(route);
      }
    } finally {
      _isNavigating = false;
    }
  }

  Future<void> _handleTimeout() async {
    _navigationTimer?.cancel();
    final networkController = Get.find<NetworkController>();
    await _navigateToNextScreen(networkController.isOnline.value);
  }

  Future<void> _handleError() async {
    _navigationTimer?.cancel();
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      final networkController = Get.find<NetworkController>();
      await _navigateToNextScreen(networkController.isOnline.value);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
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