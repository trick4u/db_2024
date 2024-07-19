

import 'package:get/get.dart';

import '../projectController/three_tasks_controller.dart';

class ThreeTasksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThreeTasksController>(() => ThreeTasksController());
  }
}
