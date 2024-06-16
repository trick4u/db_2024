import 'package:get/get.dart';

import '../controller/email_controller.dart';

class EmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailController>(() => EmailController());
  }
}