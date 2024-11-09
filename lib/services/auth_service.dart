import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);
  static const int timeoutDuration = 10;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

 Future<bool> isUserInDatabase() async {
    if (user.value == null) return false;
    
    try {
      // Create a timeout future
      final timeoutFuture = Future.delayed(
        const Duration(seconds: timeoutDuration),
        () => throw TimeoutException('Database check timed out'),
      );

      // Create the actual database check future
      final dbCheckFuture = _firestore
          .collection('users')
          .doc(user.value!.uid)
          .get()
          .then((userDoc) => userDoc.exists);

   
      final result = await Future.any([dbCheckFuture, timeoutFuture]);
      return result;
    } catch (e) {
      if (e is TimeoutException) {
        debugPrint('Database check timed out after $timeoutDuration seconds');
      } else {
        debugPrint('Error checking user in database: $e');
      }
      return false;
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
