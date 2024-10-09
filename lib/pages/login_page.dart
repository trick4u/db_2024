import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../controller/login_controller.dart';
import '../controller/theme_controller.dart';
import '../services/app_text_style.dart';
import '../services/app_theme.dart';
import '../services/toast_util.dart';

class LoginPage extends GetWidget<LoginController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'login here',
          style: TextStyle(
            fontFamily: GoogleFonts.pacifico().fontFamily,
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
                  Text(
                    'Welcome back!',
                    style: AppTextTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    return Padding(
      padding: ScaleUtil.only(left: 10, right: 10, bottom: 10),
      child: Card(
        elevation: ScaleUtil.scale(8),
        color: appTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: ScaleUtil.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Container(
            padding: ScaleUtil.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                ScaleUtil.sizedBox(height: 16),
                _buildEmailField(context),
                ScaleUtil.sizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Forgot Password',
          style: appTheme.titleLarge.copyWith(
            fontSize: ScaleUtil.fontSize(15),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close,
              color: appTheme.textColor, size: ScaleUtil.iconSize(18)),
          onPressed: () => Get.back(),
          tooltip: 'Close',
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return FadeIn(
      child: ClipRRect(
        borderRadius: ScaleUtil.circular(10),
        child: TextFormField(
          controller: emailController,
          style: appTheme.bodyMedium.copyWith(
            fontSize: ScaleUtil.fontSize(12),
          ),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(fontSize: ScaleUtil.fontSize(12)),
            filled: true,
            fillColor: appTheme.textFieldFillColor,
            border: InputBorder.none,
            contentPadding: ScaleUtil.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (_) => _updateCanSave(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildSaveButton(context),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SlideInRight(
      child: Obx(() => Container(
            decoration: BoxDecoration(
              color: canSave.value ? appTheme.colorScheme.primary : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: ScaleUtil.circular(20),
                onTap: canSave.value ? _handleSave : null,
                child: Padding(
                  padding: ScaleUtil.all(10),
                  child: Icon(
                    FontAwesomeIcons.check,
                    color: Colors.white,
                    size: ScaleUtil.iconSize(15),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  void _updateCanSave() {
    canSave.value = GetUtils.isEmail(emailController.text.trim());
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      controller.forgotPassword(emailController.text.trim());
      Get.back();
      ToastUtil.showToast(
        'Success',
        'Password reset email sent successfully',

        backgroundColor: Colors.green,
     
        duration: Duration(seconds: 2),
      );
    }
  }
}
