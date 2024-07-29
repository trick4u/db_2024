

import 'package:get/get.dart';

import '../projectController/vsion_board_controller.dart';

class VisionBoardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VisionBoardController>(() => VisionBoardController());
  }
}
