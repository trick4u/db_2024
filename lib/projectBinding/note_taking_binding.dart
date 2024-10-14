import 'package:get/get.dart';

import '../projectController/note_taking_controller.dart';

class NoteTakingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NoteTakingController>(() => NoteTakingController());
  }
}
