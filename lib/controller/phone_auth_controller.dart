import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../app_routes.dart';
import '../services/toast_util.dart';

class PhoneAuthController extends GetxController {
  // textfield controllers
  final phoneController = TextEditingController();
  // auth
  final otpController = TextEditingController();

  final RxBool isLoading = false.obs;

  final auth = FirebaseAuth.instance;

  @override
  void onInit() {
    // SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.onInit();
  }

  //phone auth method
  Future<void> phoneAuth() async {
    try {
      isLoading.value = true;
      await auth.verifyPhoneNumber(
        phoneNumber: '+91${phoneController.text}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          isLoading.value = false;
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          ToastUtil.showToast('Error', e.message.toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          Get.toNamed(AppRoutes.OTP, arguments: verificationId);

          isLoading.value = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      isLoading.value = false;
      ToastUtil.showToast('Error', e.toString());
    }
  }
}
