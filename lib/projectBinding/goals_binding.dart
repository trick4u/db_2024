
import 'package:get/get.dart';

import '../projectController/goals_screen_controller.dart';

class GoalsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GoalsScreenController>(() => GoalsScreenController());
  }
}
