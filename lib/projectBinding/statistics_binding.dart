import 'package:get/get.dart';

import '../projectController/goals_screen_controller.dart';
import '../projectController/statistics_controller.dart';

class StatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatisticsController>(() => StatisticsController());
  }
}
