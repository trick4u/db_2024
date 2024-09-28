import 'dart:async';

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
  RxBool isUsernameValid = false.obs;
  RxBool isNameValid = false.obs;
  RxBool isPasswordValid = false.obs;
  RxBool doPasswordsMatch = false.obs;

  RxBool isUsernameAvailable = false.obs;
  RxBool isCheckingUsername = false.obs;
  RxBool hasCheckedUsername = false.obs;
  RxBool isUsernameEmpty = true.obs;

  RxBool isRegisterButtonActive = false.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    usernameController.addListener(_validateUsername);
    nameController.addListener(_validateName);
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    usernameController.removeListener(_validateUsername);
    nameController.removeListener(_validateName);
    emailController.removeListener(_validateEmail);
    passwordController.removeListener(_validatePassword);
    confirmPasswordController.removeListener(_validateConfirmPassword);
    usernameController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _validateUsername() {
    final username = usernameController.text.trim();
    isUsernameValid.value = isValidUsername(username);
    isUsernameEmpty.value = username.isEmpty;
    if (isUsernameValid.value) {
      checkUsernameAvailability(username); // Pass the username here
    } else {
      isUsernameAvailable.value = false;
      hasCheckedUsername.value = false;
    }
    _updateRegisterButtonState();
  }

  void _validateName() {
    final name = nameController.text.trim();
    isNameValid.value = name.length >= 5 && name.length <= 20;
    _updateRegisterButtonState();
  }

  void _validateEmail() {
    isEmailValid.value = isValidEmail(emailController.text.trim());
    _updateRegisterButtonState();
  }

  void _validatePassword() {
    final password = passwordController.text;
    isPasswordValid.value = password.length >= 7 && password.length <= 30;
    _validateConfirmPassword();
    _updateRegisterButtonState();
  }

  void _validateConfirmPassword() {
    doPasswordsMatch.value =
        passwordController.text == confirmPasswordController.text;
    _updateRegisterButtonState();
  }

  void onUsernameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (isValidUsername(value)) {
        checkUsernameAvailability(value);
      } else {
        isUsernameAvailable.value = false;
        hasCheckedUsername.value = false;
      }
      _updateRegisterButtonState();
    });
  }

  void _updateRegisterButtonState() {
    isRegisterButtonActive.value = isUsernameValid.value &&
        isUsernameAvailable.value &&
        isNameValid.value &&
        isEmailValid.value &&
        isPasswordValid.value &&
        doPasswordsMatch.value;
  }

  bool isValidUsername(String username) {
    return username.length >= 5 && username.length <= 15;
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> checkUsernameAvailability(String username) async {
    if (!isValidUsername(username)) {
      isUsernameAvailable.value = false;
      hasCheckedUsername.value = false;
      Get.snackbar('Error', 'Invalid username format or length');
      return;
    }

    isCheckingUsername.value = true;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1) // Add this line to comply with the new rules
          .get();

      isUsernameAvailable.value = querySnapshot.docs.isEmpty;
      hasCheckedUsername.value = true;

      if (isUsernameAvailable.value) {
        Get.snackbar('Success', 'Username is available');
      } else {
        Get.snackbar('Error', 'Username is already taken');
      }
    } catch (e) {
      print('Error checking username availability: $e');
      Get.snackbar('Error', 'Failed to check username availability');
      isUsernameAvailable.value = false;
      hasCheckedUsername.value = false;
    } finally {
      isCheckingUsername.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> register() async {
    if (!isRegisterButtonActive.value) return;

    isLoading.value = true;
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await userCredential.user!.sendEmailVerification();

      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        name: nameController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      Get.snackbar('Registration Successful',
          'Please check your email to verify your account');
      Get.offAllNamed(AppRoutes.EMAILVERIFICATION);
    } catch (e) {
      Get.snackbar('Registration Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
