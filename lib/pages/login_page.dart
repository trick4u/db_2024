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
        title: Text(
          'login here',
          style: AppTextTheme.textTheme.bodyMedium,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed(AppRoutes.HOME),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: ScaleUtil.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome back you\'ve been missed!',
                    style: AppTextTheme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: ScaleUtil.height(20.0)),
                  _buildTextField(
                    controller: controller.userInputController,
                    hintText: 'Enter username or email',
                    prefixIcon: Icons.person,
                  ),
                  SizedBox(height: ScaleUtil.height(10.0)),
                  Obx(
                    () => _buildTextField(
                      controller: controller.passwordController,
                      hintText: 'Enter password',
                      obscureText: !controller.isPasswordVisible.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20.0,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ),
                  SizedBox(height: ScaleUtil.height(10.0)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        _showForgotPasswordDialog(context);
                      },
                      child: Text(
                        'Forgot Password',
                        style: AppTextTheme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                  SizedBox(height: ScaleUtil.height(10.0)),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.login,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.deepPurpleAccent,
                          backgroundColor: Colors.deepPurpleAccent,
                          padding:
                              ScaleUtil.symmetric(horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: ScaleUtil.circular(10),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Login',
                                style:
                                    AppTextTheme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                      )),
                  SizedBox(height: ScaleUtil.height(10.0)),
                  TextButton(
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.REGISTER);
                    },
                    style: TextButton.styleFrom(
                      padding:
                          ScaleUtil.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: ScaleUtil.circular(10),
                        side: BorderSide(color: Colors.deepPurpleAccent),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Register now',
                      style: AppTextTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      style: appTheme.bodyMedium,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: appTheme.textFieldFillColor,
        hintText: hintText,
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
            color: appTheme.colorScheme.primary,
            width: 1,
          ),
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Forgot Password'),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: 'Enter your email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: Text('Reset Password'),
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                controller.forgotPassword(emailController.text.trim());
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter your email',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
