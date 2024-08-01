import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tushar_db/controller/register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            _buildTextField(
              controller: controller.usernameController,
              hintText: 'Enter username',
              prefixIcon: Icons.person,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: controller.nameController,
              hintText: 'Enter name',
              prefixIcon: FontAwesomeIcons.user,
            ),
            SizedBox(height: 16),
            Obx(
              () => _buildTextField(
                controller: controller.emailController,
                hintText: 'Enter email',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                errorText:
                    controller.isEmailValid.value ? null : 'Invalid email',
              ),
            ),
            SizedBox(height: 16),
            Obx(() => _buildTextField(
                  controller: controller.passwordController,
                  hintText: 'Enter password',
                  prefixIcon: Icons.lock,
                  obscureText: !controller.isPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                )),
            SizedBox(height: 16),
            Obx(() => _buildTextField(
                  controller: controller.confirmPasswordController,
                  hintText: 'Confirm password',
                  prefixIcon: Icons.lock,
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: controller.toggleConfirmPasswordVisibility,
                  ),
                )),
            SizedBox(height: 24),
            Obx(
              () => ElevatedButton(
                
                onPressed:
                    controller.isLoading.value ? null : controller.register,
                child: controller.isLoading.value
                    ? CircularProgressIndicator()
                    : Text('Register'),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.offNamed('/login'),
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      style: Get.textTheme.bodyMedium,
      decoration: InputDecoration(
        filled: true,
        hintText: hintText,
        fillColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
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
        prefixIcon: Icon(
          prefixIcon,
          color: Get.isDarkMode ? Colors.white70 : Colors.black54,
        ),
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorStyle: TextStyle(color: Colors.red),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }
}
