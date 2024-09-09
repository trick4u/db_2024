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
                      prefixIcon: Icons.lock,
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
                        _showForgotPasswordBottomSheet(context);
                      },
                      child: Text(
                        'Forgot Password',
                        style: AppTextTheme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                  SizedBox(height: ScaleUtil.height(10.0)),
                  Obx(() => ElevatedButton(
                        onPressed: (controller.isLoginButtonActive.value &&
                                !controller.isLoading.value)
                            ? controller.login
                            : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.deepPurpleAccent,
                          backgroundColor:
                              (controller.isLoginButtonActive.value &&
                                      !controller.isLoading.value)
                                  ? Colors.deepPurpleAccent
                                  : Colors.grey,
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
    return ClipRRect(
      borderRadius: ScaleUtil.circular(10),
      child: TextField(
        controller: controller,
        style: appTheme.bodyMedium,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: appTheme.textFieldFillColor,
          hintText: hintText,
          hintStyle: appTheme.bodyMedium.copyWith(
            color: appTheme.secondaryTextColor,
            fontSize: ScaleUtil.fontSize(12),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: ScaleUtil.symmetric(horizontal: 16, vertical: 10),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  void _showForgotPasswordBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ForgotPasswordBottomSheet(),
        );
      },
    );
  }
}

class ForgotPasswordBottomSheet extends GetWidget<LoginController> {
  final AppTheme appTheme = Get.find<AppTheme>();
  final RxBool canSave = false.obs;
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    return Padding(
      padding: ScaleUtil.only(left: 20, right: 20, bottom: 50),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: appTheme.cardColor,
          borderRadius: BorderRadius.circular(
            ScaleUtil.width(20),
          ),
        ),
        child: Padding(
          padding: ScaleUtil.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Forgot Password',
                    style: appTheme.titleLarge.copyWith(
                      fontSize: ScaleUtil.fontSize(15),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: appTheme.textColor,
                        size: ScaleUtil.iconSize(15)),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              ScaleUtil.sizedBox(height: 16),
              _buildTextField('Email', emailController, _updateCanSave),
              ScaleUtil.sizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: _buildSaveButton(context),
              ),
              ScaleUtil.sizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController textController,
      VoidCallback onChanged) {
    return ClipRRect(
      borderRadius: ScaleUtil.circular(10),
      child: TextField(
        controller: textController,
        style: appTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: appTheme.textFieldFillColor,
          labelStyle: appTheme.bodyMedium.copyWith(
            color: appTheme.secondaryTextColor,
            fontSize: ScaleUtil.fontSize(12),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: ScaleUtil.symmetric(horizontal: 16, vertical: 6),
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: canSave.value ? appTheme.colorScheme.primary : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: ScaleUtil.circular(20),
              onTap: canSave.value
                  ? () async {
                      try {
                        await controller
                            .forgotPassword(emailController.text.trim());
                        Navigator.of(context).pop(); // Close the bottom sheet
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to reset password: ${e.toString()}',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    }
                  : null,
              child: Padding(
                padding: ScaleUtil.all(10),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: ScaleUtil.iconSize(15),
                ),
              ),
            ),
          ),
        ));
  }

  void _updateCanSave() {
    canSave.value = isValidEmail(emailController.text.trim());
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
