import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/email_controller.dart';

class EmailVerificationScreen extends GetWidget<EmailController> {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Column(
        children: [
          Center(
            child: Text(controller.email.value,
                style: TextStyle(fontSize: 30, color: Colors.black)),
          ),
          SizedBox(height: 20),
          Center(
            child: Text('A verification email has been sent to your email'),
          ),

          SizedBox(height: 20),
          //text button
          TextButton(
            onPressed: () {
              controller.sendVerificationEmail();
            },
            child: Text('Resend verification email'),
          ),
        ],
      ),
    );
  }
}
