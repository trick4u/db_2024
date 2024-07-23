import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';

class ProfileController extends GetxController {
  var name = 'John Doe'.obs;
  var age = 25.obs;
  var email = '   '.obs;

  //log out
  void logout() {
    FirebaseAuth.instance.signOut();
    Get.offAllNamed(AppRoutes.HOME);
  }
}
