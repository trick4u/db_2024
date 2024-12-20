import 'package:get/get.dart';
import 'package:tushar_db/projectController/profile_controller.dart';
import 'package:tushar_db/projectController/statistics_controller.dart';

import '../controller/main_screen_controller.dart';


class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainScreenController>(() => MainScreenController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.put(() => StatisticsController());
  }
}
