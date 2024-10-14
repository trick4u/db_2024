import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';

import '../models/user_model.dart';
import '../services/toast_util.dart';

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
    RxBool canCheckUsername = false.obs;

  @override
  void onInit() {
    super.onInit();
    usernameController.addListener(validateUsername);
    nameController.addListener(_validateName);
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    usernameController.removeListener(validateUsername);
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
   void validateUsername() {
    final username = usernameController.text.trim();
    isUsernameValid.value = isValidUsername(username);
    isUsernameEmpty.value = username.isEmpty;
    canCheckUsername.value = username.length >= 7;
    _updateRegisterButtonState();
  }

    void onUsernameChanged() {
    final username = usernameController.text.trim();
    isUsernameValid.value = isValidUsername(username);
    isUsernameEmpty.value = username.isEmpty;
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (isUsernameValid.value) {
        checkUsernameAvailability();
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
    return username.length >= 7 && username.length <= 15;
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

 Future<void> checkUsernameAvailability() async {
    final username = usernameController.text.trim();
    if (!isValidUsername(username)) {
      ToastUtil.showToast('Error', 'Invalid username format or length');
      return;
    }

    isCheckingUsername.value = true;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      isUsernameAvailable.value = querySnapshot.docs.isEmpty;
      hasCheckedUsername.value = true;

      if (isUsernameAvailable.value) {
        ToastUtil.showToast('Success', 'Username is available');
      } else {
        ToastUtil.showToast('Error', 'Username is already taken');
      }
    } catch (e) {
      print('Error checking username availability: $e');
      ToastUtil.showToast('Error', 'Failed to check username availability');
      isUsernameAvailable.value = false;
      hasCheckedUsername.value = false;
    } finally {
      isCheckingUsername.value = false;
      _updateRegisterButtonState();
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

      ToastUtil.showToast('Registration Successful',
          'Please check your email to verify your account');
      Get.offAllNamed(AppRoutes.EMAILVERIFICATION);
    } catch (e) {
      ToastUtil.showToast('Registration Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
