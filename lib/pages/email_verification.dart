import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_routes.dart';
import '../controller/email_controller.dart';

class EmailVerificationPage extends StatelessWidget {
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
            ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await user.reload();
                  if (user.emailVerified) {
                    Get.offAllNamed(AppRoutes.MAIN);
                  } else {
                    Get.snackbar('Not Verified', 'Please check your email and verify your account');
                  }
                }
              },
              child: Text('I have verified my email'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null && !user.emailVerified) {
                  await user.sendEmailVerification();
                  Get.snackbar('Email Sent', 'A new verification email has been sent');
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