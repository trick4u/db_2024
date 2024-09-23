import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tushar_db/constants/colors.dart';
import 'package:tushar_db/projectController/calendar_controller.dart';
import 'package:tushar_db/projectController/profile_controller.dart';
import 'package:tushar_db/projectPages/statistics_screen.dart';

import '../models/quick_event_model.dart';
import '../projectController/page_one_controller.dart';

import '../projectController/statistics_controller.dart';
import '../projectPages/awesome_noti.dart';
import '../projectPages/main_screen.dart';

import '../projectPages/page_one.dart';

import '../projectPages/page_two_calendar.dart';
import '../projectPages/profile_screen.dart';

class MainScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
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
  void onInit() {
    super.onInit();
    Get.put(PageOneController()); // Ensure this is initialized first
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => StatisticsController());
    Get.lazyPut<CalendarController>(() => CalendarController());
    scheduleDailyNotification();
    if (Platform.isIOS) {
      _setupBackgroundChannel();
      _scheduleAndroidNotification();
    }
  }

  void _setupBackgroundChannel() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'triggerDailyNotification') {
        // Ensure we're on the main thread
        await _showNotificationOnMainThread();
      }
      return null;
    });
  }

  Future<void> scheduleDailyNotification() async {
    if (Platform.isAndroid) {
      await _scheduleAndroidNotification();
    } else if (Platform.isIOS) {
      print("Daily notification scheduled for iOS via background fetch");
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
      ),
      schedule: NotificationCalendar(
        hour: 7, // 7 AM
        minute: 0,
        second: 0,
        millisecond: 0,
        repeats: true,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
      ),
    );
    print("Daily notification scheduled for Android");
  }

  Future<void> _showNotificationOnMainThread() async {
    // Use compute to run the notification creation on a separate isolate
    await compute(_isolateNotification, null);
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
