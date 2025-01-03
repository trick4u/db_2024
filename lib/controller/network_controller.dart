import 'dart:async';



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/projectPages/main_screen.dart';


import '../services/toast_util.dart';

class NetworkController extends GetxController {
  RxBool isOnline = true.obs;
  StreamSubscription? connectionStream;
  bool isInitialCheck = true;
  Timer? _navigationDebouncer;
  Timer? _debounceTimer;
  final _internetChecker = InternetConnection();
  
  @override
  void onInit() {
    super.onInit();
    checkInitialConnection();
  }

  Future<void> checkInitialConnection() async {
    try {
      // Start with assuming online to prevent blocking app launch
      isOnline.value = true;
      
      // Try to verify connection in background
      _verifyConnectionInBackground();
      
      // Start listening for future changes
      listenToConnectionChanges();
      
    } catch (e) {
      debugPrint('Initial connection check error: $e');
      // Keep default online value to allow app to proceed
    } finally {
      isInitialCheck = false;
    }
  }

  Future<void> _verifyConnectionInBackground() async {
    try {
      final hasInternet = await _internetChecker.hasInternetAccess
          .timeout(const Duration(seconds: 5), onTimeout: () => true);
      
      // Only update if it's different from current status
      if (hasInternet != isOnline.value) {
        isOnline.value = hasInternet;
        if (!hasInternet && !isInitialCheck) {
          _handleConnectionChange(hasInternet);
        }
      }
    } catch (e) {
      debugPrint('Background connection verification error: $e');
      // Keep existing status on error
    }
  }

  void listenToConnectionChanges() {
    connectionStream?.cancel();
    connectionStream = _internetChecker.onStatusChange.listen(
      (status) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 800), () {
          final isNowOnline = status == InternetStatus.connected;
          if (isOnline.value != isNowOnline) {
            isOnline.value = isNowOnline;
            _handleConnectionChange(isNowOnline);
          }
        });
      },
      onError: (error) {
        debugPrint('Connection stream error: $error');
      },
    );
  }

  void _handleConnectionChange(bool isNowOnline) {
    _navigationDebouncer?.cancel();
    _navigationDebouncer = Timer(const Duration(milliseconds: 500), () {
      final currentRoute = Get.currentRoute;
      final targetRoute = isNowOnline ? AppRoutes.AUTHWRAPPER : AppRoutes.NETWORK;
      
      if (!currentRoute.contains(isNowOnline ? 'AUTHWRAPPER' : 'NETWORK')) {
        Get.offAllNamed(targetRoute);
      }
    });
  }

  Future<void> retryConnection() async {
    try {
      final hasInternet = await _internetChecker.hasInternetAccess
          .timeout(const Duration(seconds: 5));
      
      if (hasInternet) {
        isOnline.value = true;
        Get.offAllNamed(AppRoutes.AUTHWRAPPER);
      } else {
        isOnline.value = false;
      }
    } catch (e) {
      debugPrint('Retry connection error: $e');
    }
  }

  @override
  void onClose() {
    _navigationDebouncer?.cancel();
    _debounceTimer?.cancel();
    connectionStream?.cancel();
    super.onClose();
  }
}