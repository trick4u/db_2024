import 'package:get/get.dart';

import '../projectController/page_one_controller.dart';
import '../projectController/pomodoro_controller.dart';

class PageOneBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PageOneController>(PageOneController());
     Get.put(PomodoroController());
  }
}
