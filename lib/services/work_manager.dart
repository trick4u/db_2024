

import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == WorkmanagerNotificationService.TASK_NAME) {
      final prefs = await SharedPreferences.getInstance();
      String? notificationDataString = prefs.getString(inputData!['notification_key']);
      
      if (notificationDataString != null) {
        Map<String, dynamic> notificationData = jsonDecode(notificationDataString);
        
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

        // Remove the notification data after displaying
        await prefs.remove(inputData['notification_key']);
      }
    }
    return Future.value(true);
  });
}

class WorkmanagerNotificationService {
  static const String TASK_NAME = 'com.example.scheduleNotifications';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> scheduleNotification(Map<String, dynamic> notificationData) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'notification_${notificationData['id']}';
    await prefs.setString(key, jsonEncode(notificationData));

    await Workmanager().registerOneOffTask(
      notificationData['id'].toString(),
      TASK_NAME,
      initialDelay: _getInitialDelay(notificationData['scheduledTime']),
      inputData: {'notification_key': key},
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Duration _getInitialDelay(String scheduledTimeString) {
    DateTime scheduledTime = DateTime.parse(scheduledTimeString);
    return scheduledTime.difference(DateTime.now());
  }

  static Future<void> cancelNotification(String id) async {
    await Workmanager().cancelByUniqueName(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_$id');
  }
}