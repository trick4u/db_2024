import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_routes.dart';
import '../models/user_model.dart';

class ProfileController extends GetxController {
  var age = 0.obs;

  var firebaseFireStore = FirebaseFirestore.instance;
  // textediting controller

  var newName = ' '.obs;

  var newEmail = '   '.obs;

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<String> name = ''.obs;
  final Rx<String> email = ''.obs;
  final Rx<String> username = ''.obs;
  RxBool isUsernameAvailable = false.obs;
  RxBool isCheckingUsername = false.obs;
  RxBool hasCheckedUsername = false.obs;
  Timer? _debounce;
  final RxBool isGradientReversed = false.obs;

  static const int MAX_USERNAME_LENGTH = 20; // Including "@" symbol
  static const int MIN_USERNAME_LENGTH = 4;

  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  
  RxBool isLoading = true.obs;
  RxBool hasError = false.obs;

 @override
  void onInit() {
    super.onInit();
    loadUserData();
  }


  @override
  void onReady() {
    // TODO: implement onReady
    ever(notifications, (_) => isLoading.value = false);

    super.onReady();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
   void toggleGradientDirection() {
    isGradientReversed.toggle();
  }

  //log out
  Future<void> logout() async {
    bool? shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Get.back(result: false),
          ),
          TextButton(
            child: Text('Logout'),
            onPressed: () => Get.back(result: true),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        await Get.offAllNamed(AppRoutes.HOME);
        Get.snackbar('Success', 'You have been logged out');
      } catch (error) {
        Get.snackbar('Error', 'Failed to log out: $error');
      }
    }
  }

  Future<void> deleteAccount() async {
    final TextEditingController passwordController = TextEditingController();

    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user is currently signed in.');
        return;
      }

      // Show re-authentication dialog
      bool? shouldProceed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Confirm Account Deletion'),
          content: Text(
              'Please re-enter your password to delete your account. This action cannot be undone.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Get.back(result: false),
            ),
            TextButton(
              child: Text('Proceed'),
              onPressed: () => Get.back(result: true),
            ),
          ],
        ),
      );

      if (shouldProceed != true) {
        return;
      }

      // Get the user's password
      String? password = await Get.dialog<String>(
        AlertDialog(
          title: Text('Enter Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: "Password"),
          ),
          actions: [
            TextButton(
              child: Text('Submit'),
              onPressed: () => Get.back(result: passwordController.text),
            ),
          ],
        ),
      );

      if (password == null || password.isEmpty) {
        Get.snackbar('Error', 'Password is required to delete account');
        return;
      }

      // Re-authenticate
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Delete the user account from Firebase Authentication
      await user.delete();

      // Navigate to the home screen
      await Get.offAllNamed(AppRoutes.HOME);
      Get.snackbar('Success', 'Your account has been deleted');
    } catch (error) {
      print('Error deleting account: $error');
      Get.snackbar('Error', 'Failed to delete account: $error');
    } finally {
      // Ensure the controller is always disposed
      passwordController.dispose();
    }
  }

   Future<void> loadUserData() async {
    isLoading.value = true;
    hasError.value = false;
    try {
       getUserDetails();
      isLoading.value = false;
    } catch (e) {
      print('Error loading user data: $e');
      hasError.value = true;
      isLoading.value = false;
    }
  }
  //get the user details
  void getUserDetails() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        var userDoc = await firebaseFireStore.collection('users').doc(user.uid).get();
        name.value = userDoc['name'] ?? '';
        username.value = userDoc['username'] ?? '';
        email.value = userDoc['email'] ?? '';
      } catch (e) {
        print('Error fetching user details: $e');
        throw e;
      }
    } else {
      throw Exception('No user logged in');
    }
  }

  //update the user details
  void updateUserDetails() async {
    var user = FirebaseAuth.instance.currentUser;
    UserModel userChange = UserModel(
      uid: user!.uid,
      username: usernameController.text,
      email: emailController.text,
      name: nameController.text,
    );

    if (user != null) {
      await firebaseFireStore
          .collection('users')
          .doc(user.uid)
          .update(userChange.toMap());
    }
  }



  Future<void> updateName(String newName) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        await _firestore.collection('users').doc(user.uid).update({
          'name': newName,
        });
        name.value = newName; // Update the observable
        Get.snackbar('Success', 'Name updated successfully');
        Get.back();
      }
    } catch (error) {
      Get.snackbar('Error', 'Failed to update name: $error');
    }
  }

  bool isValidUsername(String username) {
    if (!username.startsWith('@')) {
      return false;
    }
    String usernameWithoutAt = username.substring(1);
    return usernameWithoutAt.length >= MIN_USERNAME_LENGTH &&
        username.length <= MAX_USERNAME_LENGTH &&
        RegExp(r'^@[a-zA-Z0-9_]+$').hasMatch(username);
  }

  void onUsernameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      String formattedUsername = formatUsername(value);
      if (isValidUsername(formattedUsername)) {
        checkUsernameAvailability(formattedUsername);
      } else {
        isUsernameAvailable.value = false;
        hasCheckedUsername.value = false;
      }
    });
  }

  String formatUsername(String username) {
    if (!username.startsWith('@')) {
      username = '@' + username;
    }
    return username.length > MAX_USERNAME_LENGTH
        ? username.substring(0, MAX_USERNAME_LENGTH)
        : username;
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
      isUsernameAvailable.value = false;
      hasCheckedUsername.value = false;
    } finally {
      isCheckingUsername.value = false;
    }
  }

  Future<void> updateUsername(String newUsername) async {
    newUsername = formatUsername(newUsername);
    if (!isValidUsername(newUsername)) {
      Get.snackbar('Error', 'Invalid username format or length');
      return;
    }

    // If username hasn't been checked, check it now
    if (!hasCheckedUsername.value) {
      await checkUsernameAvailability(newUsername);
    }

    if (!isUsernameAvailable.value) {
      Get.snackbar('Error', 'Please choose a unique username');
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'username': newUsername,
        });
        username.value = newUsername; // Update the observable
        Get.snackbar('Success', 'Username updated successfully');
      }
    } catch (error) {
      Get.snackbar('Error', 'Failed to update username: $error');
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Change the password
        await user.updatePassword(newPassword);
        logout();
        Get.back();
        await Get.offAllNamed(AppRoutes.HOME);

        Get.snackbar('Success', 'Password changed successfully');
      }
    } catch (error) {
      Get.snackbar('Error', 'Failed to change password: $error');
    }
  }
}
