
import 'package:get/get.dart';




class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // change theme here
  // RxBool isDarkMode = false.obs;

  // late TabController tabController;

  // final FirebaseAuth auth = FirebaseAuth.instance;

  // var regexp = RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$');

  // // cloud firestore instance
  // final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // // textfield controllers
  // final emailController = TextEditingController();
  // final passwordController = TextEditingController();
  // final nameController = TextEditingController();
  // final userNameController = TextEditingController();

  // //model
  // final UserModel userModel = UserModel();

  // //formkey
  // final formKey = GlobalKey<FormState>();

  // RxBool isPasswordVisibleRegister = false.obs;

  // RxBool isPasswordVisibleLogin = false.obs;

  // // RxString
  // RxString userName = ''.obs;
  // //Rxbool for username check
  // RxBool isUsernameAvailable = false.obs;

  // @override
  // void onReady() {
  //   super.onReady();
  // }

  // @override
  // void onInit() {
  //   tabController = TabController(length: 2, vsync: this);
  //   userAuthChanges();

  //   super.onInit();
  // }

  // //dispose the tab controller
  // @override
  // void onClose() {
  //   tabController.dispose();
  //   super.onClose();
  // }

  // // if password is visible or not
  // void togglePasswordVisibility() {
  //   isPasswordVisibleRegister.value = !isPasswordVisibleRegister.value;
  // }

  // // if password is visible or not
  // void togglePasswordVisibilityLogin() {
  //   isPasswordVisibleLogin.value = !isPasswordVisibleLogin.value;
  // }

  // // create a unique username for the user and check if the username is already taken
  // Future<String> createUsername(String userName) async {
  //   String username = userName.toLowerCase();
  //   final snapshot = await firestore.collection('users').doc(username).get();
  //   if (snapshot.exists) {
  //     ToastUtil.showToast('Error', 'Username already taken');
  //     isUsernameAvailable.value = false;
  //     return '';
  //   } else {
  //     userName = username;
  //     isUsernameAvailable.value = true;
  //     ToastUtil.showToast('Success', 'Username available');

  //     return username;
  //   }
  // }

  // void changeTheme() {
  //   isDarkMode.value = !isDarkMode.value;
  //   //change theme mode
  //   Get.changeTheme(Get.isDarkMode ? ThemeData.light() : ThemeData.dark());
  // }

  // // login with email and password
  // void login() {
  //   if (emailController.text.isEmpty || passwordController.text.isEmpty) {
  //     ToastUtil.showToast('Error', 'All fields are required');
  //   } else if (!regexp.hasMatch(emailController.text)) {
  //     ToastUtil.showToast('Error', 'Invalid email');
  //   } else {
  //     auth
  //         .signInWithEmailAndPassword(
  //             email: emailController.text, password: passwordController.text)
  //         .then((value) {
  //       ToastUtil.showToast('Success', 'Login successful');
  //       Get.toNamed(AppRoutes.MAIN);
  //     }).catchError((e) {
  //       ToastUtil.showToast('Error', e.toString());
  //     });
  //   }
  // }

  // void userAuthChanges(){
  //   auth.authStateChanges().listen((User? user) {
  //     if (user == null) {
  //       print('User is currently signed out!');
  //     } else {
  //       print('User is signed in!');
  //       Get.toNamed(AppRoutes.MAIN);

  //     }
  //   });

  // }

  // // register with email and password
  // void register() {
  //   if (emailController.text.isEmpty || passwordController.text.isEmpty) {
  //     ToastUtil.showToast('Error', 'All fields are required');
  //   } else if (!regexp.hasMatch(emailController.text)) {
  //     ToastUtil.showToast('Error', 'Invalid email');
  //   } else {
  //     auth
  //         .createUserWithEmailAndPassword(
  //             email: emailController.text, password: passwordController.text)
  //         .then((value) {
  //       ToastUtil.showToast('Success', 'User registered successfully');
  //     }).then((value) {
  //       addUserToDatabase(auth.currentUser!.uid);
  //       sendVerificationEmail();
  //     }).catchError((e) {
  //       ToastUtil.showToast('Error', e.toString());
  //     });
  //   }
  // }

  // // check if the user is already present in the database
  // Future<bool> checkUser(String email) async {
  //   final snapshot = await firestore.collection('users').doc(email).get();
  //   // if the user exists
  //   if (snapshot.exists) {
  //     ToastUtil.showToast('Error', 'User already exists');

  //     return true;
  //   } else {
  //     register();
  //     return false;
  //   }
  // }

  // void addUserToDatabase(String uid) {
  //   User user = auth.currentUser!;
  //   UserModel userModel = UserModel(
  //       id: user.uid,
  //       email: user.email,
  //       name: nameController.text,
  //       userName: userNameController.text);
  //   firestore.collection('users').doc(user.uid).set(userModel.toJson());
  // }

  // // send me a verification email
  // void sendVerificationEmail() {
  //   auth.currentUser!.sendEmailVerification();
  //   ToastUtil.showToast('Success', 'Verification email sent');
  //   Get.toNamed(AppRoutes.EMAIL, arguments: emailController.text);
  // }
}
