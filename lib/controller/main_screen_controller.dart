import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';


import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tushar_db/projectController/calendar_controller.dart';
import 'package:tushar_db/projectController/profile_controller.dart';
import 'package:tushar_db/projectPages/statistics_screen.dart';


import '../projectController/page_one_controller.dart';

import '../projectController/statistics_controller.dart';


import '../projectPages/page_one.dart';

import '../projectPages/page_two_calendar.dart';
import '../projectPages/profile_screen.dart';
import '../services/notification_service.dart';
import '../services/work_manager.dart';

class MainScreenController extends GetxController
    with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  //variables
  final RxInt currentIndex = 0.obs;
  var selectedIndex = 0.obs;
  static const platform =
      MethodChannel('com.example.tushar_db/background_fetch');
  final Rx<DateTime> lastBackgroundFetchTime = Rx<DateTime>(DateTime.now());

  void changeIndex(int index) {
    selectedIndex.value = index;
    if (selectedIndex.value == 2) {
      Get.find<StatisticsController>().updateStatistics();
    }
  }

  void incrementIndex() {
    selectedIndex.value = (selectedIndex.value + 1) % 4;
  }

  final List<Widget> pages = [
    PageOneScreen(),
    CalendarPage(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  void onInit() async {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    Get.put(PageOneController()); // Ensure this is initialized first
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => StatisticsController());
    Get.lazyPut<CalendarController>(() => CalendarController());
        AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService.onActionReceivedMethod,
      onNotificationCreatedMethod: NotificationService.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationService.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationService.onDismissActionReceivedMethod,
    );
    WorkmanagerNotificationService.initialize();
    await checkAndScheduleNotification();
    _scheduleAndroidNotification();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshCurrentScreen();
    }
  }

  void refreshCurrentScreen() {
    switch (selectedIndex.value) {
      case 0:
        // Get.find<PageOneController>().refreshData();
        break;
      case 1:
        //  Get.find<CalendarController>().refreshData();
        break;
      case 2:
        Get.find<StatisticsController>().updateStatistics();
        break;
      case 3:
        Get.find<ProfileController>().loadUserData();
        break;
    }
  }



  Future<void> checkAndScheduleNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNotificationScheduled =
        prefs.getBool('isNotificationScheduled') ?? false;

    if (!isNotificationScheduled) {
      await scheduleDailyNotification();
      await prefs.setBool('isNotificationScheduled', true);
    }
  }

  Future<void> scheduleDailyNotification() async {
    try {
      if (Platform.isAndroid) {
        await _scheduleAndroidNotification();
      } else if (Platform.isIOS) {
        print("Daily notification scheduled for iOS via background fetch");
        // Implement iOS-specific scheduling if needed
      }
      print("Daily notification scheduled successfully");
    } catch (e) {
      print("Error scheduling daily notification: $e");
      // Handle the error appropriately
    }
  }

  Future<void> _scheduleAndroidNotification() async {
    await AwesomeNotifications().cancelSchedule(10);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'Daily Reminder',
        body: 'Start your day with purpose!',
        notificationLayout: NotificationLayout.Default,
         payload: {'navigation': '/main_screen'},
      ),
      schedule: NotificationCalendar(
        hour: 08,
        minute: 05,
        second: 0,
        millisecond: 0,
        repeats: true,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
      ),
    );
    print("Daily notification scheduled for Android");
  }


  static Future<void> _isolateNotification(_) async {
    // Ensure we're on the main thread before creating the notification
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          title: 'Daily Reminder',
          body: 'Start your day with purpose!',
          notificationLayout: NotificationLayout.Default,
        ),
      );
    });
  }
}
