import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';

import '../services/toast_util.dart';

class LoginController extends GetxController {
  var username = ''.obs;
  var password = ''.obs;

  // textediting controller
  final TextEditingController userInputController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isLoginButtonActive = false.obs;
  final TextEditingController passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  RxBool isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    userInputController.addListener(updateLoginButtonState);
    passwordController.addListener(updateLoginButtonState);
  }

  @override
  void onClose() {
    userInputController.removeListener(updateLoginButtonState);
    passwordController.removeListener(updateLoginButtonState);
    userInputController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void updateLoginButtonState() {
    isLoginButtonActive.value = isValidInput(userInputController.text.trim()) &&
        passwordController.text.isNotEmpty;
  }

  bool isValidInput(String input) {
    return isEmail(input) || isValidUsername(input);
  }

  bool isValidUsername(String input) {
    // Add your username validation logic here
    // For example, username should be at least 3 characters long
    return input.length >= 3;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool isEmail(String input) {
    // Simple email validation regex
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);
  }

  Future<void> login() async {
    if (!isLoginButtonActive.value) return;

    isLoading.value = true;
    try {
      String userInput = userInputController.text.trim();
      String password = passwordController.text;

      if (isEmail(userInput)) {
        await loginWithEmail(userInput, password);
      } else {
        await loginWithUsername(userInput, password);
      }

      Get.offAllNamed(AppRoutes.MAIN);
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    // Implement email login logic here
    // For example, using Firebase Auth:
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

Future<void> loginWithUsername(String username, String password) async {
  try {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw 'User not found';
    }

    String email = query.docs.first['email'];
    await loginWithEmail(email, password);
  } catch (e) {
    print('Login error: $e');
    throw 'Login failed: $e';
  }
}
  Future<void> forgotPassword(String email) async {
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ToastUtil.showToast(
        'Password Reset',
        'A password reset link has been sent to your email.',
      );
    } catch (e) {
      ToastUtil.showToast(
        'Error',
        'Failed to send password reset email: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
