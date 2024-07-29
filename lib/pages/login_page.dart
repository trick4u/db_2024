import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../controller/login_controller.dart';
import '../controller/theme_controller.dart';
import '../services/app_text_style.dart';
import '../services/app_theme.dart';

class LoginPage extends GetWidget<LoginController> {
  final appTheme = Get.find<AppTheme>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: ScaleUtil.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hello Again!',
                ),
                SizedBox(height: ScaleUtil.height(10.0)),
                Text(
                  'Welcome back you\'ve been missed!',
                  //
                ),
                SizedBox(height: ScaleUtil.height(10.0)),
                TextField(
                  controller: controller.userInputController,
                  style: appTheme.bodyMedium,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter username or email',
                    fillColor:
                        Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                        width: 1,
                      ),
                    ),
                    labelStyle: AppTextTheme.textTheme.bodySmall!.copyWith(
                      color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    hintStyle: TextStyle(
                      color: Get.isDarkMode ? Colors.white54 : Colors.black38,
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: ScaleUtil.height(10.0)),
                Obx(
                  () => TextField(
                    controller: controller.passwordController,
                    style: appTheme.bodyMedium,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Enter password',
                      fillColor:
                          Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: AppTextTheme.textTheme.bodySmall!.copyWith(
                        color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      hintStyle: TextStyle(
                        color: Get.isDarkMode ? Colors.white54 : Colors.black38,
                      ),
                      suffixIcon: InkWell(
                        onTap: controller.togglePasswordVisibility,
                        child: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20.0,
                          color:
                              Get.isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    obscureText: !controller.isPasswordVisible.value,
                  ),
                ),
                SizedBox(height: ScaleUtil.height(10.0)),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Recovery Password',
                  ),
                ),
                SizedBox(height: ScaleUtil.height(10.0)),
                Obx(() => ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : controller.login,
                      child: controller.isLoading.value
                          ? CircularProgressIndicator()
                          : Text('Login'),
                    )),
                SizedBox(height: ScaleUtil.height(10.0)),
                TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.REGISTER);
                  },
                  child: Text(
                    'Register now',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
