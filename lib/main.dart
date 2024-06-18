import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

import 'package:timezone/data/latest_10y.dart';
import 'package:tushar_db/firebase_options.dart';
import 'package:tushar_db/projectPages/main_screen.dart';
import 'package:tushar_db/theme.dart';

import 'app_routes.dart';
import 'bindings/splash_binding.dart';
import 'controller/home_controller.dart';
import 'loading_screen.dart';
import 'projectPages/page_three.dart';
import 'package:timezone/timezone.dart' as tz;


FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeTimeZone();
  
  //set localization based on real location

 // tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

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
      initialBinding: SplashBinding(),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppRoutes.routes,
      home: MainScreen(),
    );
  }
}
