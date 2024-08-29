import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'controller/network_controller.dart';

class GlobalConnectivityObserver extends WidgetsBindingObserver {
  final NetworkController networkController = Get.find<NetworkController>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      networkController.isOnline.value = true;
    }
  }
}
