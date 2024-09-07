import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_routes.dart';
import '../projectController/calendar_controller.dart';
import 'notification_tracking_service.dart';

class NotificationService extends GetxController {
  static Future<void> initialize() async {
    // Suppress the specific warning message
    if (kDebugMode) {
      FlutterError.onError = (FlutterErrorDetails details) {
        if (!details.toString().contains('awesome_notifications')) {
          FlutterError.presentError(details);
        }
      };
    }

    // Initialize AwesomeNotifications
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'event_reminders',
          channelName: 'Event Reminders',
          channelDescription: 'Notifications for event reminders',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
        ),
      ],
      debug: true,
    );
  }

  static Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledDate) async {
    // Ensure this runs on the main thread
    await runZonedGuarded(() async {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'event_reminders',
          title: title,
          body: body,
        ),
        schedule: NotificationCalendar.fromDate(date: scheduledDate),
      );
    }, (error, stack) {
      print('Error scheduling notification: $error');
    });
  }

  // Wrap other methods to ensure they run on the main thread
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    await runZonedGuarded(() async {
      // Your existing code here
    }, (error, stack) {
      print('Error in onActionReceivedMethod: $error');
    });
  }

  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    await runZonedGuarded(() async {
      // Your existing code here
    }, (error, stack) {
      print('Error in onNotificationCreatedMethod: $error');
    });
  }


  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
   await runZonedGuarded(() {
      print('Notification displayed: ${receivedNotification.id}');
      if (receivedNotification.id != null) {
        Get.find<CalendarController>().markNotificationAsDisplayed(receivedNotification.id!);
      }
     }, (error, stack) {
      print('Error in onNotificationDisplayedMethod: $error');
    });
  }

 static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    await runZonedGuarded(() async {
      // Your existing code here
    }, (error, stack) {
      print('Error in onDismissActionReceivedMethod: $error');
    });
  }
}