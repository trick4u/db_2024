import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_routes.dart';


class OtpController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString verificationId = ''.obs;

  final auth = FirebaseAuth.instance;

  final otpController = TextEditingController();

  @override
  void onInit() {
    verificationId.value = Get.arguments;
    super.onInit();
  }

  //verify otp
  Future<void> verifyOTP(String otp) async {
    try {
      isLoading.value = true;
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );
      await auth.signInWithCredential(credential);
      isLoading.value = false;
      print('verification completed');
      Get.offAllNamed(AppRoutes.MAIN);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }
}
