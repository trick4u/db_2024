import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/projectPages/main_screen.dart';
import 'package:tushar_db/services/auth_wrapper.dart';

import '../services/toast_util.dart';

class NetworkController extends GetxController {
  RxBool isOnline = true.obs;
  StreamSubscription? connectionStream;
  bool isInitialCheck = true;

  @override
  void onInit() {
    super.onInit();
    checkInitialConnection();
    listenToConnectionChanges();
  }

  Future<void> checkInitialConnection() async {
    isOnline.value = await InternetConnection().hasInternetAccess;
    if (!isOnline.value) {
      Get.offNamedUntil(AppRoutes.NETWORK, (route) => false);
    }
    isInitialCheck = false;
  }

  void listenToConnectionChanges() {
    connectionStream = InternetConnection().onStatusChange.listen((event) {
      switch (event) {
        case InternetStatus.connected:
          if (!isInitialCheck && !isOnline.value) {
            isOnline.value = true;
            navigateToMainScreen();
          }
          break;
        case InternetStatus.disconnected:
          isOnline.value = false;
          if (!isInitialCheck) {
            ToastUtil.showToast(
                'No Internet', 'Please check your internet connection',
             );
            Get.offNamedUntil(AppRoutes.NETWORK, (route) => false);
          }
          break;
      }
    });
  }

  Future<void> checkNetworkConnectivity() async {
    bool hasInternet = await InternetConnection().hasInternetAccess;
    isOnline.value = hasInternet;
    if (hasInternet) {
      // ToastUtil.showToast(
      //   'Connected',
      //   'You are online',
      //   snackPosition: SnackPosition.BOTTOM,
      // );
      navigateToMainScreen();
    } else {
      ToastUtil.showToast(
        'No Internet',
        'Please check your internet connection',
     
      );
    }
  }

  void navigateToMainScreen() {
    Get.offAll(() => MainScreen());
  }

  @override
  void onClose() {
    connectionStream?.cancel();
    super.onClose();
  }
}
