import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<bool> isUserInDatabase() async {
    if (user.value == null) return false;
    
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.value!.uid).get();
      return userDoc.exists;
    } catch (e) {
      print('Error checking user in database: $e');
      return false;
    }
  }
}