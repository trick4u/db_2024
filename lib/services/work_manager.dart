import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class WorkmanagerNotificationService {
  static const String CHECK_NOTIFICATIONS_TASK = 'com.example.checkNotifications';
  static const String RESCHEDULE_NOTIFICATIONS_TASK = 'com.example.rescheduleNotifications';

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
  }

  static Future<void> scheduleNotification(Map<String, dynamic> notificationData) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'notification_${notificationData['id']}_${notificationData['source']}';
    await prefs.setString(key, jsonEncode(notificationData));

    List<String> notificationKeys = prefs.getStringList('notification_keys') ?? [];
    if (!notificationKeys.contains(key)) {
      notificationKeys.add(key);
      await prefs.setStringList('notification_keys', notificationKeys);
    }
  }

  static Future<void> cancelNotification(String id, String source) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'notification_${id}_$source';
    await prefs.remove(key);

    List<String> notificationKeys = prefs.getStringList('notification_keys') ?? [];
    notificationKeys.remove(key);
    await prefs.setStringList('notification_keys', notificationKeys);
  }

  static Future<void> rescheduleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notificationKeys = prefs.getStringList('notification_keys') ?? [];

    for (String key in notificationKeys) {
      String? notificationDataString = prefs.getString(key);
      if (notificationDataString != null) {
        Map<String, dynamic> notificationData = jsonDecode(notificationDataString);
        DateTime scheduledTime = DateTime.parse(notificationData['scheduledTime']);

        if (scheduledTime.isAfter(DateTime.now())) {
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
            schedule: NotificationCalendar.fromDate(date: scheduledTime),
          );
        }
      }
    }
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
    }
    return Future.value(true);
  });
}

Future<void> _checkAndTriggerNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> notificationKeys = prefs.getStringList('notification_keys') ?? [];

  for (String key in notificationKeys) {
    String? notificationDataString = prefs.getString(key);
    if (notificationDataString != null) {
      Map<String, dynamic> notificationData = jsonDecode(notificationDataString);
      DateTime scheduledTime = DateTime.parse(notificationData['scheduledTime']);

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
  }
}