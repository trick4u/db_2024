

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';

import '../models/user_model.dart';

class RegisterController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  RxBool isPasswordVisible = false.obs;
  RxBool isConfirmPasswordVisible = false.obs;
  RxBool isLoading = false.obs;
  RxBool isEmailValid = true.obs;
   @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateEmail);
  }

  @override
  void onClose() {
    emailController.removeListener(_validateEmail);
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
   bool isValidEmail(String email) {
    // This regex pattern checks for a basic email format
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  void _validateEmail() {
    isEmailValid.value = isValidEmail(emailController.text.trim());
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> register() async {
  if (!isValidEmail(emailController.text.trim())) {
    Get.snackbar('Error', 'Please enter a valid email address');
    return;
  }

  if (passwordController.text != confirmPasswordController.text) {
    Get.snackbar('Error', 'Passwords do not match');
    return;
  }

  isLoading.value = true;
  try {
    // Create user with email and password
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    // Create UserModel
    UserModel newUser = UserModel(
      uid: userCredential.user!.uid,
      username: usernameController.text.trim(),
      email: emailController.text.trim(),
      name: nameController.text.trim(),
    
    );

    // Add user to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(newUser.uid)
        .set(newUser.toMap());

    // Navigate to home page
    Get.offAllNamed(AppRoutes.MAIN);
  } catch (e) {
    Get.snackbar('Registration Error', e.toString());
  } finally {
    isLoading.value = false;
  }
}
}