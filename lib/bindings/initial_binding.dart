

import 'package:get/get.dart';

import '../controller/splash_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
     Get.lazyPut<SplashController>(() => SplashController());
  }
}
