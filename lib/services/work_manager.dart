

import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == WorkmanagerNotificationService.TASK_NAME) {
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

            if (notificationData['repeat'] == true) {
              notificationData['triggerCount'] = (notificationData['triggerCount'] ?? 0) + 1;
              if (notificationData['triggerCount'] < 6) {
                // Schedule next notification
                notificationData['scheduledTime'] = DateTime.now()
                    .add(Duration(minutes: notificationData['interval']))
                    .toIso8601String();
                await prefs.setString(key, jsonEncode(notificationData));
              } else {
                // Remove after 6 repetitions
                notificationKeys.remove(key);
                await prefs.remove(key);
              }
            } else {
              // Remove non-repeating notification after firing
              notificationKeys.remove(key);
              await prefs.remove(key);
            }
          }
        }
      }

      await prefs.setStringList('notification_keys', notificationKeys);
    }
    return Future.value(true);
  });
}

class WorkmanagerNotificationService {
  static const String TASK_NAME = 'com.example.checkNotifications';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    // Register periodic task
    await Workmanager().registerPeriodicTask(
      'periodicNotificationCheck',
      TASK_NAME,
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
    String key = 'notification_${notificationData['id']}';
    await prefs.setString(key, jsonEncode(notificationData));

    List<String> notificationKeys = prefs.getStringList('notification_keys') ?? [];
    if (!notificationKeys.contains(key)) {
      notificationKeys.add(key);
      await prefs.setStringList('notification_keys', notificationKeys);
    }
  }

  static Future<void> cancelNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'notification_$id';
    await prefs.remove(key);

    List<String> notificationKeys = prefs.getStringList('notification_keys') ?? [];
    notificationKeys.remove(key);
    await prefs.setStringList('notification_keys', notificationKeys);
  }
}
