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
import 'package:tushar_db/services/auth_wrapper.dart';

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
import 'services/app_theme.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/notification_tracking_service.dart';
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
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
  Get.put(AuthService());
  await initializeTimeZone();
  if (Platform.isAndroid) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }
  String soundSource =
      Platform.isIOS ? 'success.wav' : 'resource://raw/notification_sound';
  print('WorkManager initialized!');

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
          channelKey: 'quickschedule',
          channelName: 'Reminder Notifications',
          channelDescription:
              'Notification channel for daily motivational quotes',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          enableLights: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'event_reminders',
          channelName: 'Reminder Notifications',
          channelDescription:
              'Notification channel for daily motivational quotes',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: false,
          playSound: true,
          soundSource: soundSource,
          enableLights: true,
          enableVibration: true,
        ),
      ],
      debug: true);

  // Initialize NotificationTrackingService
  await Get.putAsync(() => NotificationTrackingService().init());

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
  AwesomeNotifications().setGlobalBadgeCounter(0);

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
    final appTheme = Get.put(AppTheme());

    return Obx(() => GetMaterialApp(
          title: 'DoBoard Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: AppTheme.lightColorScheme,
            textTheme: TextTheme(
              titleLarge: appTheme.titleLarge,
              bodyMedium: appTheme.bodyMedium,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: AppTheme.darkColorScheme,
            textTheme: TextTheme(
              titleLarge: appTheme.titleLarge,
              bodyMedium: appTheme.bodyMedium,
            ),
          ),
          themeMode: appTheme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialBinding: InitialBinding(),
          initialRoute: AppRoutes.AUTHWRAPPER,
          home: MyHomePage(),
          getPages: AppRoutes.routes,
          builder: (context, child) {
            ScaleUtil();

            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
        ));
  }
}
