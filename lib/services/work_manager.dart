import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class WorkmanagerNotificationService {
  static const String CHECK_NOTIFICATIONS_TASK =
      'com.example.checkNotifications';
  static const String RESCHEDULE_NOTIFICATIONS_TASK =
      'com.example.rescheduleNotifications';
  static const String DAILY_NOTIFICATION_TASK = 'com.example.dailyNotification';
  static const String VISION_BOARD_CHECK_NOTIFICATIONS_TASK =
      'com.example.visionBoardCheckNotifications';
  static const String VISION_BOARD_RESCHEDULE_NOTIFICATIONS_TASK =
      'com.example.visionBoardRescheduleNotifications';
  static const String RESCHEDULE_ON_BOOT_TASK = 'com.example.rescheduleOnBoot';

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      'periodicNotificationCheck',
      CHECK_NOTIFICATIONS_TASK,
      frequency: Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
    await Workmanager().registerOneOffTask(
      'rescheduleNotificationsTask',
      RESCHEDULE_NOTIFICATIONS_TASK,
      initialDelay: Duration(seconds: 5),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
    await Workmanager().registerPeriodicTask(
      'dailyNotificationTask',
      DAILY_NOTIFICATION_TASK,
      frequency: Duration(days: 1),
      initialDelay: _getInitialDelay(),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
    await Workmanager().registerOneOffTask(
      'rescheduleOnBootTask',
      RESCHEDULE_ON_BOOT_TASK,
      initialDelay: Duration(seconds: 5),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
    await Workmanager().registerPeriodicTask(
      'visionBoardPeriodicNotificationCheck',
      VISION_BOARD_CHECK_NOTIFICATIONS_TASK,
      frequency: Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
    await Workmanager().registerOneOffTask(
      'visionBoardRescheduleNotificationsTask',
      VISION_BOARD_RESCHEDULE_NOTIFICATIONS_TASK,
      initialDelay: Duration(seconds: 5),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  static Duration _getInitialDelay() {
    final now = DateTime.now();
    final eightAM = DateTime(now.year, now.month, now.day, 07, 45);
    if (now.isAfter(eightAM)) {
      return eightAM.add(Duration(days: 1)).difference(now);
    } else {
      return eightAM.difference(now);
    }
  }

  static Future<void> triggerDailyNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'Daily Reminder',
        body: 'Start your day with purpose!',
        notificationLayout: NotificationLayout.Default,
        largeIcon: 'resource://drawable/notification_icon',
        color: Colors.blue,
        icon: 'resource://drawable/notification_icon',
      ),
    );
  }

  static Future<void> scheduleNotification(
      Map<String, dynamic> notificationData) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'notification_${notificationData['id']}';
    await prefs.setString(key, jsonEncode(notificationData));

    List<String> notificationKeys =
        prefs.getStringList('notification_keys') ?? [];
    if (!notificationKeys.contains(key)) {
      notificationKeys.add(key);
      await prefs.setStringList('notification_keys', notificationKeys);
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationData['id'],
        channelKey: notificationData['channelKey'],
        title: notificationData['title'],
        body: notificationData['body'],
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(
        date: DateTime.parse(notificationData['scheduledTime']),
        repeats: true,
      ),
    );

    print("Notification scheduled for ${notificationData['scheduledTime']}");
  }

  static Future<void> cancelNotification(String id, String source) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'notification_${id}_$source';
    await prefs.remove(key);

    List<String> notificationKeys =
        prefs.getStringList('notification_keys') ?? [];
    notificationKeys.remove(key);
    await prefs.setStringList('notification_keys', notificationKeys);
  }

  static Future<void> rescheduleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notificationKeys =
        prefs.getStringList('notification_keys') ?? [];

    for (String key in notificationKeys) {
      String? notificationDataString = prefs.getString(key);
      if (notificationDataString != null) {
        Map<String, dynamic> notificationData =
            jsonDecode(notificationDataString);
        await scheduleNotification(notificationData);
      }
    }
  }

  // Vision Board specific methods
  static Future<void> scheduleVisionBoardNotification(
      Map<String, dynamic> notificationData) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'visionBoard_notification_${notificationData['id']}';
    await prefs.setString(key, jsonEncode(notificationData));

    List<String> notificationKeys =
        prefs.getStringList('visionBoard_notification_keys') ?? [];
    if (!notificationKeys.contains(key)) {
      notificationKeys.add(key);
      await prefs.setStringList(
          'visionBoard_notification_keys', notificationKeys);
    }
  }

  static Future<void> cancelVisionBoardNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'visionBoard_notification_$id';
    await prefs.remove(key);

    List<String> notificationKeys =
        prefs.getStringList('visionBoard_notification_keys') ?? [];
    notificationKeys.remove(key);
    await prefs.setStringList(
        'visionBoard_notification_keys', notificationKeys);
  }

  static Future<void> rescheduleVisionBoardNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notificationKeys =
        prefs.getStringList('visionBoard_notification_keys') ?? [];

    for (String key in notificationKeys) {
      String? notificationDataString = prefs.getString(key);
      if (notificationDataString != null) {
        Map<String, dynamic> notificationData =
            jsonDecode(notificationDataString);
        DateTime scheduledTime =
            DateTime.parse(notificationData['scheduledTime']);

        if (scheduledTime.isAfter(DateTime.now())) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: notificationData['id'],
              channelKey: notificationData['channelKey'],
              title: notificationData['title'],
              body: notificationData['body'],
              bigPicture: notificationData['bigPicture'],
              notificationLayout: NotificationLayout.BigPicture,
              category: NotificationCategory.Reminder,
              payload: notificationData['payload'],
            ),
            schedule: NotificationCalendar.fromDate(date: scheduledTime),
          );
        } else {
          await prefs.remove(key);
          notificationKeys.remove(key);
        }
      }
    }

    await prefs.setStringList(
        'visionBoard_notification_keys', notificationKeys);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case WorkmanagerNotificationService.CHECK_NOTIFICATIONS_TASK:
        await _checkAndTriggerNotifications();
        break;
      case WorkmanagerNotificationService.RESCHEDULE_NOTIFICATIONS_TASK:
        await WorkmanagerNotificationService.rescheduleNotifications();
        break;
      case WorkmanagerNotificationService.DAILY_NOTIFICATION_TASK:
        await WorkmanagerNotificationService.triggerDailyNotification();
        break;
      case WorkmanagerNotificationService.VISION_BOARD_CHECK_NOTIFICATIONS_TASK:
        await _checkAndTriggerVisionBoardNotifications();
        break;
      case WorkmanagerNotificationService
            .VISION_BOARD_RESCHEDULE_NOTIFICATIONS_TASK:
        await WorkmanagerNotificationService
            .rescheduleVisionBoardNotifications();
        break;
    }

    return Future.value(true);
  });
}

Future<void> _checkAndTriggerNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> notificationKeys =
      prefs.getStringList('notification_keys') ?? [];

  for (String key in notificationKeys) {
    String? notificationDataString = prefs.getString(key);
    if (notificationDataString != null) {
      Map<String, dynamic> notificationData =
          jsonDecode(notificationDataString);
      DateTime scheduledTime =
          DateTime.parse(notificationData['scheduledTime']);

      if (scheduledTime.isBefore(DateTime.now())) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationData['id'],
            channelKey: notificationData['channelKey'],
            title: notificationData['title'],
            body: notificationData['body'],
            category: NotificationCategory.Reminder,
            notificationLayout: NotificationLayout.Default,
            criticalAlert: true,
            wakeUpScreen: true,
          ),
        );

        // Remove the notification after triggering
        await prefs.remove(key);
        notificationKeys.remove(key);
      }
    }
  }

  await prefs.setStringList('notification_keys', notificationKeys);
}

Future<void> _checkAndTriggerVisionBoardNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> notificationKeys =
      prefs.getStringList('visionBoard_notification_keys') ?? [];

  for (String key in notificationKeys) {
    String? notificationDataString = prefs.getString(key);
    if (notificationDataString != null) {
      Map<String, dynamic> notificationData =
          jsonDecode(notificationDataString);
      DateTime scheduledTime =
          DateTime.parse(notificationData['scheduledTime']);

      if (scheduledTime.isBefore(DateTime.now())) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationData['id'],
            channelKey: notificationData['channelKey'],
            title: notificationData['title'],
            body: notificationData['body'],
            bigPicture: notificationData['bigPicture'],
            notificationLayout: NotificationLayout.BigPicture,
            category: NotificationCategory.Reminder,
            payload: notificationData['payload'],
          ),
        );

        // Remove the notification after triggering
        await prefs.remove(key);
        notificationKeys.remove(key);
      }
    }
  }

  await prefs.setStringList('visionBoard_notification_keys', notificationKeys);
}

class BootReceiver {
  static Future<void> initialize() async {
    await Workmanager().registerOneOffTask(
      'rescheduleNotificationsTask',
      WorkmanagerNotificationService.RESCHEDULE_NOTIFICATIONS_TASK,
      initialDelay: Duration(seconds: 5),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
    await Workmanager().registerOneOffTask(
      'visionBoardRescheduleNotificationsTask',
      WorkmanagerNotificationService.VISION_BOARD_RESCHEDULE_NOTIFICATIONS_TASK,
      initialDelay: Duration(seconds: 5),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }
}
