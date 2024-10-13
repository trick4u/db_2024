import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_routes.dart';

import '../services/toast_util.dart';

class EmailVerificationPage extends StatelessWidget {
  final RxBool isLoading = false.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Email Verification')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please verify your email address'),
            SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: isLoading.value
                      ? null
                      : () async {
                          isLoading.value = true;
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await user.reload();
                            user = FirebaseAuth.instance.currentUser;
                            if (user != null && user.emailVerified) {
                              Get.offAllNamed(AppRoutes.MAIN);
                            } else {
                              ToastUtil.showToast('Not Verified',
                                  'Please check your email and verify your account');
                            }
                          }
                          isLoading.value = false;
                        },
                  child: isLoading.value
                      ? CircularProgressIndicator()
                      : Text('I have verified my email'),
                )),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null && !user.emailVerified) {
                  await user.sendEmailVerification();
                  ToastUtil.showToast(
                      'Email Sent', 'A new verification email has been sent');
                }
              },
              child: Text('Resend verification email'),
            ),
          ],
        ),
      ),
    );
  }
}

