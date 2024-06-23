

import 'package:get/get.dart';

import '../controller/main_screen_controller.dart';
import '../controller/network_controller.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainScreenController>(() => MainScreenController());

  }
}