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

  @override
  void onInit() {
    super.onInit();
    getUserDetails();
  }

  //log out
  void logout() async {
    FirebaseAuth.instance.currentUser?.reload();
    await FirebaseAuth.instance.signOut();

    await Get.offAllNamed(AppRoutes.HOME);
    print('Logged out');
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
        content: Text('Please re-enter your password to delete your account. This action cannot be undone.'),
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

  //get the user details
  void getUserDetails() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await firebaseFireStore
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value) {
        name.value = value['name'];
        username.value = value['username'];

        email.value = value['email'];
      });
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

    Future<void> loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
      name.value = userData['name'] ?? '';
      email.value = userData['email'] ?? '';
      username.value = userData['username'] ?? '';
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
        name.value = newName;  // Update the observable
        Get.snackbar('Success', 'Name updated successfully');
      }
    } catch (error) {
      Get.snackbar('Error', 'Failed to update name: $error');
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
        await _firestore.collection('users').doc(user.uid).update({
          'email': newEmail,
        });
        email.value = newEmail;  // Update the observable
        Get.snackbar('Success', 'Email updated successfully');
      }
    } catch (error) {
      Get.snackbar('Error', 'Failed to update email: $error');
    }
  }

  Future<void> updateUsername(String newUsername) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Check if username is unique (implement this check)
        await _firestore.collection('users').doc(user.uid).update({
          'username': newUsername,
        });
        username.value = newUsername;  // Update the observable
        Get.snackbar('Success', 'Username updated successfully');
      }
    } catch (error) {
      Get.snackbar('Error', 'Failed to update username: $error');
    }
  }

bool isValidUsername(String username) {
  // Add your validation logic here
  // For example:
  // - Minimum 3 characters, maximum 20
  // - Only alphanumeric characters and underscores
  final RegExp usernameRegex = RegExp(r'^[a-z0-9_]{3,20}$');
  return usernameRegex.hasMatch(username);
}

Future<void> changePassword(String currentPassword, String newPassword) async {
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
      
      Get.snackbar('Success', 'Password changed successfully');
    }
  } catch (error) {
    Get.snackbar('Error', 'Failed to change password: $error');
  }
}
}
