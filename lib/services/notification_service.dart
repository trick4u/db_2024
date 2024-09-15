import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../projectController/calendar_controller.dart';
import '../projectController/page_one_controller.dart';

class NotificationService extends GetxController {
  static Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledDate) async {
    try {
      bool success = await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'quickschedule',
          title: title,
          body: body,
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
          criticalAlert: true,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledDate,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );

      if (success) {
        print('Notification scheduled successfully: ID $id for ${scheduledDate.toIso8601String()}');
      } else {
        print('Failed to schedule notification: ID $id');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    try {
      print('Notification action received: ${receivedAction.id}');
      // Handle the action here
    } catch (e) {
      print('Error in onActionReceivedMethod: $e');
    }
  }

  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    try {
      print('Notification created: ${receivedNotification.id}');
      // You can add any logic needed when a notification is created
    } catch (e) {
      print('Error in onNotificationCreatedMethod: $e');
    }
  }

  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    try {
      print('Notification displayed: ${receivedNotification.id}');
      
      if (receivedNotification.id != null) {
        await Get.find<CalendarController>().markNotificationAsDisplayed(receivedNotification.id!);
      }

      Map<String, String?>? payload = receivedNotification.payload;

      bool repeat = payload?['repeat'] == 'true';
      int interval = int.tryParse(payload?['interval'] ?? '0') ?? 0;

      if (repeat && interval > 0) {
        final PageOneController controller = Get.find<PageOneController>();

        String body = receivedNotification.body ?? '';
        int? notificationId = receivedNotification.id;
        DateTime initialTriggerTime = DateTime.now().add(Duration(minutes: interval));

        await controller.schedulePeriodicNotifications(
          body,
          interval,
          repeat,
          notificationId: notificationId,
          initialTriggerTime: initialTriggerTime,
        );
      }
    } catch (e) {
      print('Error in onNotificationDisplayedMethod: $e');
    }
  }

  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    try {
      print('Notification dismissed: ${receivedAction.id}');
      // Handle notification dismissal here
    } catch (e) {
      print('Error in onDismissActionReceivedMethod: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await AwesomeNotifications().cancel(id);
      print('Notification cancelled: ID $id');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }
}