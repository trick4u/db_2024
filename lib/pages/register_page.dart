import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tushar_db/controller/register_controller.dart';

import '../app_routes.dart';
import '../services/app_text_style.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';

class RegisterPage extends GetView<RegisterController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (d) async {
        Get.offAllNamed(AppRoutes.HOME);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'register here',
            style: AppTextTheme.textTheme.displaySmall,
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
                    Obx(() => _buildTextField(
                          controller: controller.usernameController,
                          labelText: 'Username',
                          hintText: 'Enter username (5-15 characters)',
                          prefixIcon: Icons.person,
                          suffixIcon: controller.isUsernameEmpty.value
                              ? null
                              : IconButton(
                                  icon: controller.isCheckingUsername.value
                                      ? CircularProgressIndicator()
                                      : Icon(Icons.check),
                                  onPressed:
                                      controller.checkUsernameAvailability,
                                ),
                          errorText: controller.hasCheckedUsername.value &&
                                  !controller.isUsernameAvailable.value
                              ? 'Username unavailable'
                              : null,
                          onEditingComplete:
                              controller.onUsernameEditingComplete,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                          ],
                        )),
                    SizedBox(height: ScaleUtil.height(10.0)),
                    _buildTextField(
                      controller: controller.nameController,
                      labelText: 'Name',
                      hintText: 'Enter name',
                      prefixIcon: FontAwesomeIcons.user,
                    ),
                    SizedBox(height: ScaleUtil.height(10.0)),
                    Obx(() => _buildTextField(
                          controller: controller.emailController,
                          labelText: 'Email',
                          hintText: 'Enter email',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          errorText: controller.isEmailValid.value
                              ? null
                              : 'Invalid email',
                        )),
                    SizedBox(height: ScaleUtil.height(10.0)),
                    Obx(() => _buildTextField(
                          controller: controller.passwordController,
                          labelText: 'Password',
                          hintText: 'Enter password',
                          prefixIcon: Icons.lock,
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
                        )),
                    SizedBox(height: ScaleUtil.height(10.0)),
                    Obx(() => _buildTextField(
                          controller: controller.confirmPasswordController,
                          labelText: 'Confirm Password',
                          hintText: 'Confirm password',
                          prefixIcon: Icons.lock,
                          obscureText:
                              !controller.isConfirmPasswordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20.0,
                            ),
                            onPressed:
                                controller.toggleConfirmPasswordVisibility,
                          ),
                        )),
                    SizedBox(height: ScaleUtil.height(20.0)),
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.register,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.deepPurpleAccent,
                            backgroundColor: Colors.deepPurpleAccent,
                            padding: ScaleUtil.symmetric(
                                horizontal: 30, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: ScaleUtil.circular(10),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Register',
                                  style: AppTextTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                        )),
                    SizedBox(height: ScaleUtil.height(10.0)),
                    TextButton(
                      onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
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
                        'Login',
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    IconData? prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? errorText,
    void Function(String)? onChanged,
    VoidCallback? onEditingComplete,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return ClipRRect(
      borderRadius: ScaleUtil.circular(10),
      child: TextField(
        controller: controller,
        style: appTheme.bodyMedium,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          filled: true,
          fillColor: appTheme.textFieldFillColor,
          labelStyle: appTheme.bodyMedium.copyWith(
            color: appTheme.secondaryTextColor,
            fontSize: ScaleUtil.fontSize(12),
          ),
          hintStyle: appTheme.bodyMedium.copyWith(
            color: appTheme.secondaryTextColor,
            fontSize: ScaleUtil.fontSize(10),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: ScaleUtil.symmetric(horizontal: 16, vertical: 6),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon,
          errorText: errorText,
          errorStyle: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
