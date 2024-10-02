import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tushar_db/bindings/network_binding.dart';
import 'package:tushar_db/projectController/calendar_controller.dart';
import 'package:tushar_db/projectController/profile_controller.dart';
import 'package:tushar_db/projectController/statistics_controller.dart';

import '../controller/home_controller.dart';
import '../controller/main_screen_controller.dart';
import '../controller/network_controller.dart';
import '../controller/splash_controller.dart';
import '../controller/work_manager_controller.dart';
import '../projectController/page_one_controller.dart';
import '../projectController/pomodoro_controller.dart';
import '../services/scale_util.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());

    Get.lazyPut<MainScreenController>(() => MainScreenController(),
        fenix: true);

    Get.lazyPut<PageOneController>(() => PageOneController(), fenix: true);
    Get.lazyPut<CalendarController>(() => CalendarController(), fenix: true);
    Get.lazyPut<StatisticsController>(() => StatisticsController(),
        fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    
       Get.lazyPut<PomodoroController>(() => PomodoroController(), fenix: true);
    // Get.put(NetworkController(), permanent: true);
  }
}
