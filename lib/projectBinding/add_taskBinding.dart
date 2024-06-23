

import 'package:get/get.dart';

import '../projectController/add_task_controller.dart';

class AddTaskbinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddTaskController>(() => AddTaskController());
  }
}
