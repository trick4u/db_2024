

import 'package:get/get.dart';

import '../projectController/page_threeController.dart';

class PageThreebinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PageThreecontroller>(() => PageThreecontroller());
  }
}