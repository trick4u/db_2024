import 'package:get/get.dart';
import 'package:tushar_db/bindings/register_binding.dart';
import 'package:tushar_db/pages/register_page.dart';
import 'package:tushar_db/projectPages/vision_board_page.dart';
import 'package:tushar_db/services/auth_service.dart';
import 'package:tushar_db/services/auth_wrapper.dart';

import 'bindings/email_binding.dart';
import 'bindings/home_binding.dart';
import 'bindings/login_binding.dart';
import 'bindings/main_screen_binding.dart';
import 'bindings/network_binding.dart';
import 'bindings/otp_binding.dart';
import 'bindings/phone_binding.dart';
import 'bindings/initial_binding.dart';
import 'pages/email_verification.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/network_screen.dart';
import 'projectBinding/add_everything_binding.dart';
import 'projectBinding/add_taskBinding.dart';
import 'projectBinding/eat_the_frog_binding.dart';
import 'projectBinding/note_taking_binding.dart';
import 'projectBinding/statistics_binding.dart';
import 'projectBinding/journal_binding.dart';
import 'projectBinding/notes_binding.dart';
import 'projectBinding/notification_binding.dart';
import 'projectBinding/page_one_binding.dart';
import 'projectBinding/profile_bindings.dart';
import 'projectBinding/three_tasks_binding.dart';
import 'projectBinding/vision_board_binding.dart';
import 'projectController/journal_controller.dart';
import 'projectPages/add_everyting.dart';
import 'projectPages/add_task.dart';
import 'projectPages/eat_the_frog.dart';
import 'projectPages/journalEntryScreen.dart';
import 'projectPages/note_taking_screen.dart';
import 'projectPages/statistics_screen.dart';
import 'projectPages/journal_page.dart';
import 'projectPages/main_screen.dart';
import 'pages/otp_screen.dart';
import 'pages/phone_auth.dart';
import 'pages/splash_screen.dart';
import 'projectPages/notes_page.dart';
import 'projectPages/notification_screen.dart';
import 'projectPages/page_one.dart';
import 'projectPages/profile_screen.dart';
import 'projectPages/three_tasks_screen.dart';
import 'widgets/three_day.dart';

class AppRoutes {
  static const String HOME = '/home';
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
  // add task
  static const String ADDTASK = '/addTask';

  //network
  static const String NETWORK = '/network';
  // goals
  static const String STATS = '/stats';
  //page one
  static const String PAGEONE = '/pageOne';
  //add everything
  static const String ADDEVERYTHING = '/addEverything';
  //eat the frog
  static const String EATTHEFROG = '/eatTheFrog';
  //three tasksscreen
  static const String THREETASKSSCREEN = '/threeTasksScreen';
  //notes
  static const String NOTES = '/notes';
  static const String VISIONBOARD = '/visionBoard';
  static const String AUTHWRAPPER = '/authWrapper';
  static const String JOURNAL = '/journal';
  static const String EMAILVERIFICATION = '/email-verification';
  static const String NOTIFICAION = '/notification';
  static const String NOTETAKING = '/noteTaking';
  //journal entry screen
  static const String JOURNALENTRYSCREEN = '/journalEntryScreen';

  static List<GetPage> routes = [
    GetPage(
      name: JOURNALENTRYSCREEN,
      page: () => JournalEntryScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<JournalController>(() => JournalController());
      }),
    ),
    GetPage(
        name: NOTIFICAION,
        page: () => DisplayedNotificationsScreen(),
        binding: DisplayedNotificationsBinding()),
    GetPage(
      name: EMAILVERIFICATION,
      page: () => EmailVerificationPage(),
    ),
    GetPage(
      name: JOURNAL,
      page: () => JournalPage(),
      binding: JournalBinding(),
    ),
    GetPage(
      name: AUTHWRAPPER,
      page: () => AuthWrapper(),
    ),
    GetPage(
      name: REGISTER,
      page: () => RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: VISIONBOARD,
      page: () => VisionBoardPage(),
      binding: VisionBoardBinding(),
    ),
    GetPage(
      name: LOGIN,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: NOTES,
      page: () => NotesPage(),
      binding: NotesBinding(),
    ),
    GetPage(
      name: ADDEVERYTHING,
      page: () => AddEveryting(),
      binding: AddEverythingBinding(),
    ),

    GetPage(
      name: PAGEONE,
      page: () => PageOneScreen(),
      binding: PageOneBinding(),
    ),
    GetPage(
      name: STATS,
      page: () => StatisticsScreen(),
      binding: StatisticsBinding(),
    ),
    GetPage(
      name: NETWORK,
      page: () => NetworkScreen(),
      binding: NetworkBinding(),
    ),
    GetPage(
      name: SPLASH,
      page: () => SplashScreen(),
      binding: InitialBinding(),
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
    GetPage(
      name: MAIN,
      page: () => MainScreen(),
      binding: MainScreenBinding(),
    ),

    GetPage(
      name: ADDTASK,
      page: () => AddTaskScreen(),
      binding: AddTaskbinding(),
    ),
    //eat the frog
    GetPage(
      name: EATTHEFROG,
      page: () => EatTheFrog(),
      binding: EatTheFrogBinding(),
    ),
    //three tasksscreen
    GetPage(
      name: THREETASKSSCREEN,
      page: () => CommentScreen(),
      binding: ThreeTasksBinding(),
      transition: Transition.cupertinoDialog,
    ),
    // profile
    GetPage(
      name: PROFILE,
      page: () => ProfileScreen(),
      binding: ProfileBindings(),
    ),
    //note taking
    GetPage(
      name: NOTETAKING,
      page: () => NoteTakingScreen(),
      binding: NoteTakingBinding(),
    ),
  ];
}
