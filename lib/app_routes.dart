import 'package:get/get.dart';


import 'bindings/email_binding.dart';
import 'bindings/home_binding.dart';
import 'bindings/main_screen_binding.dart';
import 'bindings/otp_binding.dart';
import 'bindings/phone_binding.dart';
import 'bindings/splash_binding.dart';
import 'pages/email_verification.dart';
import 'pages/home_page.dart';
import 'projectPages/main_screen.dart';
import 'pages/otp_screen.dart';
import 'pages/phone_auth.dart';
import 'pages/splash_screen.dart';

class AppRoutes {
  static const String HOME = '/';
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String PROFILE = '/profile';
  static const String SETTINGS = '/settings';
  static const String ABOUT = '/about';
  static const String CONTACT = '/contact';
  static const String PHONEAUTH = '/phoneauth';

  //splash screen
  static const String SPLASH = '/splash';
  //otp screen
  static const String OTP = '/otp';
  //main screen
  static const String MAIN = '/main';
  // email verification
  static const String EMAIL = '/emailVerification';

  

  static List<GetPage> routes = [
    GetPage(
      name: SPLASH,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: HOME,
      page: () => MyHomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: PHONEAUTH,
      page: () => PhoneAuthScreen(),
      binding: PhoneBinding(),
    ),
    GetPage(
      name: OTP,
      page: () => OtpScreen(),
      binding: OtpBinding(),
    ),
    GetPage(name: MAIN, page: () => MainScreen(), binding: MainScreenBinding(),),
    GetPage(name: EMAIL, page: () => EmailVerificationScreen(), binding: EmailBinding(),),

  
  ];
}
