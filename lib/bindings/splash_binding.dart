

import 'package:get/get.dart';


import '../controller/home_controller.dart';
import '../controller/main_screen_controller.dart';
import '../controller/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
    Get.lazyPut<MainScreenController>(() => MainScreenController());
  
       
  }
}