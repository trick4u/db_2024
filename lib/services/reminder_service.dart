import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminder_model.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId; // Assume this is set when initializing the service

  ReminderService(this.userId);

  Future<void> saveReminder(ReminderModel reminder) async {
    // Save to Firestore
    await _firestore.collection('users').doc(userId).collection('reminders').add(reminder.toFirestore());
    
    // Schedule the notification
    await scheduleNotification(reminder);
  }

  Future<void> rescheduleAllReminders() async {
    QuerySnapshot reminderSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .get();

    for (QueryDocumentSnapshot doc in reminderSnapshot.docs) {
      ReminderModel reminder = ReminderModel.fromFirestore(doc);
      await scheduleNotification(reminder);
    }
  }

  Future<void> scheduleNotification(ReminderModel reminder) async {
    int notificationId = reminder.notificationId ?? reminder.id.hashCode;

    DateTime now = DateTime.now();
    DateTime scheduledDate = reminder.triggerTime ?? now.add(Duration(minutes: reminder.time));

    if (scheduledDate.isBefore(now)) {
      if (reminder.repeat) {
        // For repeating reminders, find the next occurrence
        while (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(Duration(minutes: reminder.time));
        }
      } else {
        // For non-repeating reminders that are in the past, don't schedule
        return;
      }
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'reminders_channel',
        title: 'Reminder',
        body: reminder.reminder,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: reminder.repeat
          ? NotificationCalendar(
              hour: scheduledDate.hour,
              minute: scheduledDate.minute,
              second: 0,
              millisecond: 0,
              repeats: true,
            )
          : NotificationCalendar.fromDate(date: scheduledDate),
    );

    // Update the reminder in Firestore with the new trigger time and notification ID
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(reminder.id)
        .update({
      'triggerTime': Timestamp.fromDate(scheduledDate),
      'notificationId': notificationId,
    });
  }

  Future<void> deleteReminder(String reminderId) async {
    // Delete from Firestore
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(reminderId)
        .delete();

    // Cancel the notification
    await AwesomeNotifications().cancel(reminderId.hashCode);
  }

  Future<void> updateReminder(ReminderModel updatedReminder) async {
    // Update in Firestore
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(updatedReminder.id)
        .update(updatedReminder.toFirestore());

    // Cancel the old notification
    await AwesomeNotifications().cancel(updatedReminder.id.hashCode);

    // Schedule the new notification
    await scheduleNotification(updatedReminder);
  }
}