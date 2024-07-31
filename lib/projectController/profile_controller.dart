import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';

class ProfileController extends GetxController {
  var name = 'John Doe'.obs;
  var age = 25.obs;
  var email = '   '.obs;
  var firebaseFireStore = FirebaseFirestore.instance;

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

  //get the user details
  void getUserDetails() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await firebaseFireStore
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value) {
        name.value = value['username'];

        email.value = value['email'];

        print('User details fetched');

        print("Email: ${email.value}");
        print("Name: ${name.value}");
      });
    }
  }
}
