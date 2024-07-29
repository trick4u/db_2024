import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';

class ProfileController extends GetxController {
  var name = 'John Doe'.obs;
  var age = 25.obs;
  var email = '   '.obs;
  var firebaseFireStore = FirebaseFirestore.instance;

  //log out
  void logout() async {
    FirebaseAuth.instance.currentUser?.reload();
    await FirebaseAuth.instance.signOut();

    await Get.offAllNamed(AppRoutes.HOME);
    print('Logged out');
  }

  //delete account
  void deleteAccount() {
    FirebaseAuth.instance.currentUser!.delete();
    // delete all data from the database
    firebaseFireStore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();

    Get.offAllNamed(AppRoutes.HOME);
  }
}
