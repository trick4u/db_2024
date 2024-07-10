

import 'package:get/get.dart';

import '../projectController/notes_page_controller.dart';

class NotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotesPageController>(() => NotesPageController());
  }
}