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
  final TextEditingController confirmPasswordController =
      TextEditingController();

  RxBool isPasswordVisible = false.obs;
  RxBool isConfirmPasswordVisible = false.obs;
  RxBool isLoading = false.obs;
  RxBool isEmailValid = true.obs;

  RxBool isUsernameAvailable = false.obs;
  RxBool isCheckingUsername = false.obs;
   RxBool hasCheckedUsername = false.obs;
     RxBool isUsernameEmpty = true.obs;


 @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateEmail);
    usernameController.addListener(_checkUsernameEmpty);
  }


  @override
  void onClose() {
    emailController.removeListener(_validateEmail);
    usernameController.removeListener(_checkUsernameEmpty);
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

   void _checkUsernameEmpty() {
    isUsernameEmpty.value = usernameController.text.trim().isEmpty;
    if (isUsernameEmpty.value) {
      hasCheckedUsername.value = false;
      isUsernameAvailable.value = false;
    }
  }

    bool isValidUsername(String username) {
    return username.length >= 5 && username.length <= 15;
  }

  Future<void> checkUsernameAvailability() async {
    final username = usernameController.text.trim();
    if (!isValidUsername(username)) {
      Get.snackbar('Error', 'Username must be between 5 and 15 characters');
      return;
    }

    isCheckingUsername.value = true;
    hasCheckedUsername.value = false;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      isUsernameAvailable.value = querySnapshot.docs.isEmpty;
      hasCheckedUsername.value = true;

      if (isUsernameAvailable.value) {
        Get.snackbar('Success', 'Username is available');
      } else {
        Get.snackbar('Error', 'Username is already taken');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to check username availability');
    } finally {
      isCheckingUsername.value = false;
    }
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

    if (!isValidUsername(usernameController.text.trim())) {
      Get.snackbar('Error', 'Username must be between 5 and 15 characters');
      return;
    }

    if (!isUsernameAvailable.value) {
      Get.snackbar('Error', 'Please choose a unique username');
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
