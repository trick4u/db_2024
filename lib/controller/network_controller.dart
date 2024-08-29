import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tushar_db/app_routes.dart';

class NetworkController extends GetxController {
  RxBool isOnline = true.obs;

  StreamSubscription? connectionStream;

  @override
  void onInit() {
    super.onInit();
    InternetConnection().onStatusChange.listen((event) {
      switch (event) {
        case InternetStatus.connected:
          isOnline.value = true;
          // Get.offNamedUntil(AppRoutes.MAIN, (route) => false);
          break;
        case InternetStatus.disconnected:
          isOnline.value = false;
          Get.snackbar('No Internet', 'Please check your internet connection',
              snackPosition: SnackPosition.BOTTOM);
          Get.offNamedUntil(AppRoutes.NETWORK, (route) => false);
          break;
        default:
      }
    });
  }

  // update the connection status
  void updateConnectionStatus(bool status) {
    isOnline.value = status;
  }

  @override
  void onClose() {
    connectionStream?.cancel();
    super.onClose();
  }
}
