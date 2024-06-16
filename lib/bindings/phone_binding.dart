

import 'package:get/get.dart';

import '../controller/phone_auth_controller.dart';

class PhoneBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhoneAuthController>(() => PhoneAuthController());
  }
}
 
