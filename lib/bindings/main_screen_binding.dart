

import 'package:get/get.dart';


import '../controller/main_screen_controller.dart';
import '../projectController/page_one_controller.dart';


class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainScreenController>(() => MainScreenController());
    Get.lazyPut<PageOneController>(() => PageOneController());
  

  }
}