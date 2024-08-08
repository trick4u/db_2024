
import 'package:get/get.dart';

import '../projectController/displaying_botifications_controller.dart';

class DisplayedNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DisplayedNotificationsController>(() => DisplayedNotificationsController());
  }
}