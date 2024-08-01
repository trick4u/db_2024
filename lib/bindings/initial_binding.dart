import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tushar_db/bindings/network_binding.dart';

import '../controller/home_controller.dart';
import '../controller/main_screen_controller.dart';
import '../controller/network_controller.dart';
import '../controller/splash_controller.dart';
import '../controller/work_manager_controller.dart';
import '../projectController/page_one_controller.dart';
import '../services/scale_util.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());

    Get.lazyPut<MainScreenController>(() => MainScreenController(),
        fenix: true);

    Get.lazyPut<PageOneController>(() => PageOneController(), fenix: true);
    Get.put(NetworkController(), permanent: true);
  }
}
