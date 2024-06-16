import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../controller/phone_auth_controller.dart';

class PhoneAuthScreen extends GetWidget<PhoneAuthController> {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Phone Auth'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              focusNode: FocusNode(),
              controller: controller.phoneController,
              decoration: InputDecoration(
                hintText: 'Enter Phone Number',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.phoneAuth();
              },
              child: Text('Send OTP'),
            ),

            // otp textfield

            TextField(
              controller: controller.otpController,
              decoration: InputDecoration(
                hintText: 'Enter OTP',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
               // controller.verifyOTP('123456');
              },
              child: Text('Verify OTP'),
            ),
          
          ],
        ),
      ),
    );
  }
}
