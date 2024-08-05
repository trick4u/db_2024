

import 'package:get/get.dart';

import '../projectController/journal_controller.dart';

class JournalBinding extends Bindings{
   @override
  void dependencies() {
    Get.lazyPut<JournalController>(() => JournalController());
  }
}
