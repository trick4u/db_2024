import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../projectController/calendar_controller.dart';
import '../projectController/page_one_controller.dart';

class NotificationService extends GetxController {
  static Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDate) async {
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
        print(
            'Notification scheduled successfully: ID $id for ${scheduledDate.toIso8601String()}');
      } else {
        print('Failed to schedule notification: ID $id');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.DismissAction ||
        receivedAction.buttonKeyPressed == 'MARK_DONE') {
      String? documentId = receivedAction.payload?['documentId'];
      if (documentId != null) {
        final PageOneController controller = Get.find<PageOneController>();
        await controller.deleteReminder(documentId);
        print('Reminder removed after user interaction: $documentId');
      }
    }
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    try {
      print('Notification created: ${receivedNotification.id}');
      // You can add any logic needed when a notification is created
    } catch (e) {
      print('Error in onNotificationCreatedMethod: $e');
    }
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    try {
      print('Notification displayed: ${receivedNotification.id}');

      if (receivedNotification.id != null) {
        final CalendarController controller = Get.find<CalendarController>();
        await controller.markNotificationAsDisplayed(receivedNotification.id!);
      }

      Map<String, String?>? payload = receivedNotification.payload;

      bool repeat = payload?['repeat'] == 'true';
      int interval = int.tryParse(payload?['interval'] ?? '0') ?? 0;
      String? documentId = payload?['documentId'];
      int triggerCount = int.tryParse(payload?['triggerCount'] ?? '0') ?? 0;

      triggerCount++;

      if ((!repeat || triggerCount >= 6) && documentId != null) {
        // Remove the reminder from the list and cancel future notifications
        final PageOneController controller = Get.find<PageOneController>();
        await controller.deleteReminder(documentId);
        print('Non-repeating reminder removed after triggering: $documentId');
      } else if (repeat &&
          triggerCount < 6 &&
          interval > 0 &&
          documentId != null) {
        final PageOneController controller = Get.find<PageOneController>();

        // Calculate the next trigger time
        DateTime nextTriggerTime =
            DateTime.now().add(Duration(minutes: interval));

        // Schedule the next notification
        await controller.schedulePeriodicNotifications(
            receivedNotification.body ?? '', interval, repeat,
            notificationId: receivedNotification.id,
            initialTriggerTime: nextTriggerTime,
            documentId: documentId,
            triggerCount: triggerCount);

        print(
            'Rescheduled repeating notification: ID ${receivedNotification.id}, Next trigger: $nextTriggerTime, Interval: $interval minutes, TriggerCount: $triggerCount');
      }
    } catch (e) {
      print('Error in onNotificationDisplayedMethod: $e');
    }
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
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
