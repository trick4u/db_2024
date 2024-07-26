import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';

import 'package:timezone/data/latest_10y.dart';
import 'package:tushar_db/controller/network_controller.dart';
import 'package:tushar_db/controller/theme_controller.dart';
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
import 'projectController/calendar_controller.dart';

import 'projectPages/awesome_noti.dart';
import 'projectPages/page_three.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'services/app_text_style.dart';
import 'services/notification_service.dart';
import 'services/scale_util.dart';

FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'fetchAndDisplayQuote') {
      final now = DateTime.now();
      final scheduledHour = inputData?['hour'] as int? ?? 9;
      final scheduledMinute = inputData?['minute'] as int? ?? 30;

      if (now.hour == scheduledHour && now.minute == scheduledMinute) {
        final controller = Get.put(NotificationController());
        await controller.fetchAndDisplayQuote();
      }
    }
    return Future.value(true);
  });
}
void main() async {
  await GetStorage.init();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeTimeZone();
 if (Platform.isAndroid) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }
  print('WorkManager initialized!');
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
            ledColor: Colors.blue),
        NotificationChannel(
          channelKey: 'quote_channel',
          channelName: 'Daily Quote Notifications',
          channelDescription:
              'Notification channel for daily motivational quotes',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: 'quickschedule',
          channelName: 'Reminder Notifications',
          channelDescription:
              'Notification channel for daily motivational quotes',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Low,
          channelShowBadge: true,
        ),
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
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationService.onActionReceivedMethod,
    onNotificationCreatedMethod:
        NotificationService.onNotificationCreatedMethod,
    onNotificationDisplayedMethod:
        NotificationService.onNotificationDisplayedMethod,
    onDismissActionReceivedMethod:
        NotificationService.onDismissActionReceivedMethod,
  );

  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    } else {
      print('Notification Allowed');
    }
  });



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
    final HomeController homeController = Get.put(HomeController());
    final ThemeController themeController = Get.put(ThemeController());
    final appTheme =
   Get.put(AppTheme());

 return Obx(() => GetMaterialApp(
          title: 'DoBoard Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
        colorScheme: AppTheme.lightColorScheme,
        textTheme: TextTheme(
          titleLarge: appTheme.titleLarge,
          bodyMedium: appTheme.bodyMedium,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: AppTheme.darkColorScheme,
        textTheme: TextTheme(
          titleLarge: appTheme.titleLarge,
          bodyMedium: appTheme.bodyMedium,
        ),
      ),
           themeMode: appTheme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialBinding: InitialBinding(),
          initialRoute: AppRoutes.HOME,
          getPages: AppRoutes.routes,
          builder: (context, child) {
            ScaleUtil();
            
           
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
        ));
  }
}