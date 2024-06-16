import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../app_routes.dart';


class EmailController extends GetxController {
  RxString email = ''.obs;

  final FirebaseAuth auth = FirebaseAuth.instance;

  Timer? timer;

  @override
  void onReady() {
    email.value = Get.arguments;

    super.onReady();
  }

  @override
  void onInit() {
    // check email verification periodically

    callPeriodically();

    checkEmailVerification();
    super.onInit();
  }

  void callPeriodically() {
    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (auth.currentUser!.emailVerified == true) {
        Get.snackbar('Success', 'Email is verified');
        Get.offAllNamed(AppRoutes.MAIN);
        timer.cancel();
      } else {
        checkEmailVerification();
      }
    });
  }

  void checkEmailVerification() {
    email.value = auth.currentUser!.email!;
    auth.currentUser!.reload();
    if (auth.currentUser!.emailVerified == true) {
      Get.snackbar('Success', 'Email is verified');

     
      //stop the timer

      //navigate to the main page
      Get.offAllNamed(AppRoutes.MAIN);
      // cancelTimer();
    } else {
      Get.snackbar('Error', 'Email is not verified');
    }
  }

  // send verification email
  void sendVerificationEmail() {
    auth.currentUser!.sendEmailVerification();
    Get.snackbar('Success', 'Verification email sent');
  }
}
