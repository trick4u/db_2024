import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
          centerTitle: false,
          title: Text(
            'register here',
            style: TextStyle(
              fontFamily: GoogleFonts.badScript().fontFamily,
              fontSize: ScaleUtil.fontSize(25),
              fontWeight: FontWeight.w100,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
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
                          hintText: 'enter username (7-15 characters)',
                          prefixIcon: Icons.person,
                          suffixIcon: controller.canCheckUsername.value
                              ? IconButton(
                                  icon: controller.isCheckingUsername.value
                                      ? CircularProgressIndicator(
                                          strokeWidth: 2,
                                        )
                                      : Icon(Icons.check),
                                  onPressed:
                                      controller.checkUsernameAvailability,
                                )
                              : null,
                          errorText: controller.hasCheckedUsername.value &&
                                  !controller.isUsernameAvailable.value
                              ? 'username unavailable'
                              : null,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                          ],
                          onChanged: (value) => controller.validateUsername(),
                        )),
                    SizedBox(height: ScaleUtil.height(10.0)),
                    Obx(() => _buildTextField(
                          controller: controller.nameController,
                          hintText: 'enter name (5-20 characters)',
                          prefixIcon: FontAwesomeIcons.user,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
                          ],
                        )),
                    SizedBox(height: ScaleUtil.height(10.0)),
                    Obx(() => _buildTextField(
                          controller: controller.emailController,
                          hintText: 'enter email',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          errorText: controller.isEmailValid.value
                              ? null
                              : 'invalid email',
                        )),
                    SizedBox(height: ScaleUtil.height(10.0)),
                    Obx(() => _buildTextField(
                          controller: controller.passwordController,
                          hintText: 'enter password (7-30 characters)',
                          prefixIcon: Icons.lock,
                          obscureText: !controller.isPasswordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: ScaleUtil.iconSize(15),
                              color: appTheme.secondaryTextColor,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(30),
                          ],
                        )),
                    SizedBox(height: ScaleUtil.height(10.0)),
                    Obx(() => _buildTextField(
                          controller: controller.confirmPasswordController,
                          hintText: 'confirm password',
                          prefixIcon: Icons.lock,
                          obscureText:
                              !controller.isConfirmPasswordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: ScaleUtil.iconSize(15),
                              color: appTheme.secondaryTextColor,
                            ),
                            onPressed:
                                controller.toggleConfirmPasswordVisibility,
                          ),
                          errorText: controller.doPasswordsMatch.value
                              ? null
                              : 'passwords do not match',
                        )),
                    SizedBox(height: ScaleUtil.height(20.0)),
                    Obx(() => ElevatedButton(
                          onPressed: (controller.isRegisterButtonActive.value &&
                                  !controller.isLoading.value)
                              ? controller.register
                              : null,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.deepPurpleAccent,
                            backgroundColor:
                                (controller.isRegisterButtonActive.value &&
                                        !controller.isLoading.value)
                                    ? Colors.deepPurpleAccent
                                    : Colors.grey,
                            padding: ScaleUtil.symmetric(
                                horizontal: 30, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: ScaleUtil.circular(10),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'register',
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
                        'login',
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
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
      child: TextField(
        controller: controller,
        style: appTheme.bodyMedium,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
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
          contentPadding: ScaleUtil.symmetric(horizontal: 16, vertical: 10),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon,
                  color: appTheme.secondaryTextColor,
                  size: ScaleUtil.iconSize(20))
              : null,
          suffixIcon: suffixIcon,
          errorText: errorText,
          errorStyle: appTheme.bodyMedium.copyWith(
            fontSize: ScaleUtil.fontSize(10),
          ),
        ),
      ),
    );
  }
}
