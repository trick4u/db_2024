import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

import 'package:timezone/data/latest_10y.dart';
import 'package:tushar_db/controller/network_controller.dart';
import 'package:tushar_db/firebase_options.dart';
import 'package:tushar_db/pages/splash_screen.dart';
import 'package:tushar_db/projectPages/main_screen.dart';
import 'package:tushar_db/theme.dart';

import 'app_routes.dart';
import 'bindings/initial_binding.dart';
import 'controller/home_controller.dart';
import 'controller/work_manager_controller.dart';
import 'loading_screen.dart';
import 'pages/home_page.dart';
import 'projectPages/page_three.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          title: 'Periodic Reminder',
          body: 'This is your reminder notification! okay',
        ),
        schedule: NotificationInterval(
            interval: 5 * 60, // 15 minutes in seconds
            timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
            repeats: true));
    return Future.value(true);
  });

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeTimeZone();
  // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  // Workmanager().registerPeriodicTask(
  //   "1",
  //   "simplePeriodicTask",
  //   frequency: Duration(minutes: 15),
  //   inputData: {"data": "TusharPeriodicTask"},
  // );

  // await Workmanager().registerOneOffTask(
  //   "2",
  //   "simpleOneOffTask",
  //   initialDelay: Duration(minutes: 1),
  //   inputData: {"data": "TusharOneOffTask"},
  // );

  // print('Registered all tasks!');

  await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.blue)
      ],
      debug: true);

  AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings("@mipmap/ic_launcher");

  DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true);

  InitializationSettings initializationSettings =
      InitializationSettings(android: androidSettings, iOS: iosSettings);

  bool? initialized = await notificationsPlugin.initialize(
      initializationSettings, onDidReceiveNotificationResponse: (response) {
    log(response.payload.toString());
  });

  log("Notifications: $initialized");

  runApp(const MyApp());
}

Future<void> initializeTimeZone() async {
  // Initialize the timezone data
  initializeTimeZones();
  // Get the device's current timezone
  String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  // Set the local timezone
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController themeController = Get.put(HomeController());

    return GetMaterialApp(
      title: 'DoBoard Demo',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      theme: lightTheme,
      themeMode:
          themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.HOME,
      getPages: AppRoutes.routes,
      // home: MyHomePage(),
    );
  }
}
