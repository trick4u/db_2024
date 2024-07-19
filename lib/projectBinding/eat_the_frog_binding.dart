

import 'package:get/get.dart';

import '../projectController/eat_the_frog_controller.dart';

class EatTheFrogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EatTheFrogController>(() => EatTheFrogController());
  }
}