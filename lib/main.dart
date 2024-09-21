import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/data/latest_10y.dart';
import 'package:tushar_db/controller/network_controller.dart';
import 'package:tushar_db/controller/theme_controller.dart';
import 'package:tushar_db/firebase_options.dart';
import 'package:tushar_db/pages/splash_screen.dart';
import 'package:tushar_db/projectPages/main_screen.dart';
import 'package:tushar_db/services/auth_wrapper.dart';

import 'app_routes.dart';
import 'bindings/initial_binding.dart';

import 'projectPages/awesome_noti.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'services/app_text_style.dart';
import 'services/app_theme.dart';
import 'services/auth_service.dart';

import 'services/notification_service.dart';
import 'services/notification_tracking_service.dart';

import 'services/scale_util.dart';

void callbackDispatcher() {
  // Workmanager().executeTask((task, inputData) async {
  //   if (task == 'fetchAndDisplayQuote') {
  //     final now = DateTime.now();
  //     final scheduledHour = inputData?['hour'] as int? ?? 9;
  //     final scheduledMinute = inputData?['minute'] as int? ?? 30;

  //     if (now.hour == scheduledHour && now.minute == scheduledMinute) {
  //       final controller = Get.put(NotificationController());
  //       await controller.fetchAndDisplayQuote();
  //     }
  //   }
  //   return Future.value(true);
  // });
}

void main() async {
  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!details.toString().contains('awesome_notifications')) {
        FlutterError.presentError(details);
      }
    };
  }

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SharedPreferences.getInstance();

  // Initialize NotificationService

  await GetStorage.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);

  Get.put(AuthService());
  final appTheme = Get.put(AppTheme());
  appTheme.updateStatusBarColor();

  if (Platform.isAndroid) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }
  // String soundSource =
  //     Platform.isIOS ? 'success.wav' : 'resource://raw/notification_sound';
  print('WorkManager initialized!');

  await AwesomeNotifications().initialize(
      null,
      [
        // NotificationChannel(
        //     channelKey: 'basic_channel',
        //     channelName: 'Basic notifications',
        //     channelDescription: 'Notification channel for basic tests',
        //     defaultColor: const Color(0xFF9D50DD),
        //     ledColor: Colors.blue),
        NotificationChannel(
        channelKey: 'quickschedule',
        channelName: 'Reminder Notifications',
        channelDescription: 'Notification channel for reminders and events',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        enableLights: true,
        enableVibration: true,
        playSound: true,
        criticalAlerts: true,
      ),
        NotificationChannel(
          channelKey: 'event_reminders',
          channelName: 'Reminder Notifications',
          channelDescription:
              'Notification channel for daily motivational quotes',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          defaultRingtoneType: DefaultRingtoneType.Notification,
          // channelShowBadge: false,
          playSound: true,
          // soundSource: soundSource,
          enableLights: true,
          enableVibration: true,
        ),
        // NotificationChannel(
        //   channelKey: 'vision_board_reminders',
        //   channelName: 'Vision Board Reminders',
        //   channelDescription:
        //       'Notification channel for vision board item reminders',
        //   defaultColor: Color(0xFF9D50DD),
        //   ledColor: Colors.purple,
        //   importance: NotificationImportance.Max,
        //   defaultPrivacy: NotificationPrivacy.Private,
        //   // channelShowBadge: true,
        //   playSound: true,
        //   // soundSource: soundSource,
        //   enableLights: true,
        //   enableVibration: true,
        // ),
      ],
    );

  // Initialize NotificationTrackingService
  await Get.putAsync(() => NotificationTrackingService().init());

  // AndroidInitializationSettings androidSettings =
  //     AndroidInitializationSettings("@mipmap/ic_launcher");

  // DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestCriticalPermission: true,
  //     requestSoundPermission: true);

  // InitializationSettings initializationSettings =
  //     InitializationSettings(android: androidSettings, iOS: iosSettings);

  // bool? initialized = await notificationsPlugin.initialize(
  //     initializationSettings, onDidReceiveNotificationResponse: (response) {
  //   log(response.payload.toString());
  // });

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();

    return Obx(() => GetMaterialApp(
          title: 'DoBoard Demo',
          debugShowCheckedModeBanner: false,
          theme: appTheme.themeData,
          darkTheme: appTheme.themeData,
          themeMode: appTheme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialBinding: InitialBinding(),
          home: SplashScreen(), // Change this line
          getPages: [
            ...AppRoutes.routes,
          ],
          builder: (context, child) {
            ScaleUtil.init(context);
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
        ));
  }
}
