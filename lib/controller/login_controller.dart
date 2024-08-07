import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';

class LoginController extends GetxController {
  var isPasswordVisible = false.obs;

  var username = ''.obs;
  var password = ''.obs;

  // textediting controller
  final TextEditingController userInputController = TextEditingController();
  var passwordController = TextEditingController();
  var emailController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool isEmail(String input) {
    // Simple email validation regex
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);
  }

  Future<void> login() async {
    isLoading.value = true;
    try {
      String userInput = userInputController.text.trim();
      String password = passwordController.text;

      if (isEmail(userInput)) {
        // Login with email
        await loginWithEmail(userInput, password);
      } else {
        // Login with username
        await loginWithUsername(userInput, password);
      }

      // If login is successful, navigate to home page
      Get.offAllNamed(AppRoutes.MAIN, predicate: (route) => false);
    } catch (e) {
      Get.snackbar(
        'Login Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
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
    // Implement username login logic here
    // For example, query Firestore to get the email associated with the username
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
  }

   Future<void> forgotPassword(String email) async {
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Password Reset',
        'A password reset link has been sent to your email.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send password reset email: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

}
