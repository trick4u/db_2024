

import 'package:get/get.dart';

import '../projectController/add_everything_controller.dart';

class AddEverythingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddEverythingController>(() => AddEverythingController());
  }
}
