

import 'package:get/get.dart';

import '../projectController/vision_board_controller.dart';

class VisionBoardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VisionBoardController>(() => VisionBoardController());
  }
}
