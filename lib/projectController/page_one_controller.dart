import 'dart:async';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';

import '../models/goals_model.dart';
import '../models/quick_event_model.dart';
import '../models/reminder_model.dart';
import '../projectPages/awesome_noti.dart';
import '../services/notification_service.dart';
import 'add_task_controller.dart';
import 'package:http/http.dart' as http;

class PageOneController extends GetxController {
  //variables

  // text field controller
  late TextEditingController reminderTextController = TextEditingController();
  RxInt timeSelected = 0.obs;
  var fireStoreInstance = FirebaseFirestore.instance;
  var repeat = false.obs;
  var text = "".obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  var goalsList = <Goals>[].obs;

  RxInt carouselPageIndex = 0.obs;
  // Rx<GoalsModel> allGoals = GoalsModel().obs;

  final RxList<GoalsModel> allGoals = RxList<GoalsModel>([]);
  RxList<ReminderModel> allReminders = <ReminderModel>[].obs;
  //rx status
  Rx<RxStatus> goalsStatus = RxStatus.loading().obs;

  var greeting = ''.obs;
  RxList<QuickEventModel> upcomingEvents = <QuickEventModel>[].obs;
  RxList<QuickEventModel> pendingEvents = <QuickEventModel>[].obs;
  RxList<QuickEventModel> completedEvents = <QuickEventModel>[].obs;
  User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxString selectedListType = ''.obs;
  Rx<DateTime?> nextNotificationTime = Rx<DateTime?>(null);

  CollectionReference get eventsCollection {
    return _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .collection('events');
  }

  CollectionReference get remindersCollection {
    return _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .collection('reminders');
  }

  //pomodor timer
  var isRunning = false.obs;
  var isBreak = false.obs;
  var seconds = 0.obs;
  var workDuration = 25 * 60; // 25 minutes
  var breakDuration = 5 * 60; // 5 minutes
  late AudioPlayer audioPlayer;
  final Color startColor = Color(0xFF2196F3);
  final Color endColor = Color(0xFFF44336);
  late Timer _colorTimer;
  var backgroundColor = Color(0xFF2196F3).obs;
  final player = AudioPlayer();
  var isPlaying = false.obs;
  var currentStreamIndex = 0.obs;

  var isLoading = true.obs;
  final Dio dio = Dio();

  @override
  void onInit() {
    //   getAllGoals();
    fetchAllEvents();
    fetchAllReminders();

    reminderTextController = TextEditingController();
    originalFontColor.value = chips[0].fontColor!;

    originalBackgroundColor = chips[0].backgroundColor as MaterialColor;

    chips[0].fontColor = Colors.black;
    chips[0].backgroundColor = Colors.blue;

    super.onInit();
  }

  //onReady
  @override
  void onReady() {
    //getAllGoals();

    updateGreeting();
  }

  @override
  void dispose() {
    reminderTextController.dispose();
    audioPlayer.dispose();

    super.dispose();
  }

  //for reminders
  Future<void> updateReminder(String reminderId, String newReminder, int newTime, bool repeat) async {
    try {
      DateTime newTriggerTime = DateTime.now().add(Duration(minutes: newTime));
      await remindersCollection.doc(reminderId).update({
        "reminder": newReminder,
        "time": newTime,
        "repeat": repeat,
        "triggerTime": Timestamp.fromDate(newTriggerTime),
      });

      // Reschedule the notification
      await AwesomeNotifications().cancel(int.parse(reminderId));
      await schedulePeriodicNotifications(newReminder, newTime, repeat);

      Get.back();
      fetchAllReminders(); // Refresh the list
    } catch (e) {
      print('Error updating reminder: $e');
      Get.snackbar('Error', 'Failed to update reminder');
    }
  }
  

  // void showEditReminderDialog(ReminderModel reminder) {
  //   final TextEditingController reminderController =
  //       TextEditingController(text: reminder.reminder);
  //   final TextEditingController timeController =
  //       TextEditingController(text: reminder.time.toString());

  //   Get.dialog(
  //     AlertDialog(
  //       title: Text('Edit Reminder'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           TextField(
  //             controller: reminderController,
  //             decoration: InputDecoration(labelText: 'Reminder'),
  //           ),
  //           TextField(
  //             controller: timeController,
  //             decoration: InputDecoration(labelText: 'Time (minutes)'),
  //             keyboardType: TextInputType.number,
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           child: Text('Cancel'),
  //           onPressed: () => Get.back(),
  //         ),
  //         TextButton(
  //           child: Text('Save'),
  //           onPressed: () {
  //             updateReminder(
  //               reminder.id,
  //               reminderController.text,
  //               int.tryParse(timeController.text) ?? reminder.time,
  //             );
  //             Get.back();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void fetchAllReminders() {
    if (currentUser == null) return;

    remindersCollection.snapshots().listen((querySnapshot) {
      allReminders.value = querySnapshot.docs
          .map((doc) => ReminderModel.fromFirestore(doc))
          .toList();
      allReminders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      update();
    });
  }

  void deleteReminder(String reminderId) async {
    if (currentUser == null) return;
    try {
      await remindersCollection.doc(reminderId).delete();
      Get.snackbar('Success', 'Reminder deleted successfully');
    } catch (e) {
      print('Error deleting reminder: $e');
      Get.snackbar('Error', 'Failed to delete reminder');
    }
  }

  void toggleReminderCompletion(String reminderId, bool isCompleted) {
    remindersCollection.doc(reminderId).update({'isCompleted': isCompleted});
    fetchAllReminders();
  }

  void setSelectedListType(String listType) {
    selectedListType.value = listType;
    getSelectedEvents();
  }

  RxList<QuickEventModel> getSelectedEvents() {
    switch (selectedListType.value) {
      case 'upcoming':
        return upcomingEvents;
      case 'pending':
        return pendingEvents;
      case 'completed tasks':
        return completedEvents;
      default:
        return RxList<QuickEventModel>([]);
    }
  }

  void deleteEvent(String eventId) async {
    if (currentUser == null) return;
    try {
      await eventsCollection.doc(eventId).delete();
      fetchAllEvents(); // Refresh all event lists
      Get.snackbar('Success', 'Event deleted successfully');
    } catch (e) {
      print('Error deleting event: $e');
      Get.snackbar('Error', 'Failed to delete event');
    }
  }

  // New archive function
  void archiveEvent(String eventId) async {
    if (currentUser == null) return;
    try {
      await eventsCollection.doc(eventId).update({'isArchived': true});
      fetchAllEvents(); // Refresh all event lists
      Get.snackbar('Success', 'Event archived successfully');
    } catch (e) {
      print('Error archiving event: $e');
      Get.snackbar('Error', 'Failed to archive event');
    }
  }

  void fetchAllEvents() {
    if (currentUser == null) return;

    eventsCollection.snapshots().listen((querySnapshot) {
      List<QuickEventModel> allEvents = querySnapshot.docs
          .map((doc) => QuickEventModel.fromFirestore(doc))
          .toList();

      // Sort all events by date
      allEvents.sort((a, b) => a.date.compareTo(b.date));

      DateTime now = DateTime.now();

      upcomingEvents.value = allEvents
          .where(
              (event) => event.isCompleted != true && event.date.isAfter(now))
          .toList();

      pendingEvents.value = allEvents
          .where(
              (event) => event.isCompleted != true && event.date.isBefore(now))
          .toList();

      completedEvents.value =
          allEvents.where((event) => event.isCompleted == true).toList();
      update();
    });
  }

  Future<void> updateEvent(
      String eventId, Map<String, dynamic> updatedData) async {
    if (currentUser == null) return;
    try {
      // Fetch the current event data
      DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();
      Map<String, dynamic> currentData =
          eventDoc.data() as Map<String, dynamic>;

      // Prepare the update data
      Map<String, dynamic> finalUpdateData = {};

      // Compare and only include changed fields
      updatedData.forEach((key, value) {
        if (key == 'date' ||
            key == 'startTime' ||
            key == 'endTime' ||
            key == 'reminderTime') {
          // For date and time fields, only update if explicitly provided and different
          if (value != null) {
            Timestamp currentTimestamp = currentData[key];
            Timestamp newTimestamp =
                (value is DateTime) ? Timestamp.fromDate(value) : value;
            if (currentTimestamp != newTimestamp) {
              finalUpdateData[key] = newTimestamp;
            }
          }
        } else if (currentData[key] != value) {
          // For non-date fields, update if different
          finalUpdateData[key] = value;
        }
      });

      // Only perform the update if there are changes
      if (finalUpdateData.isNotEmpty) {
        await eventsCollection.doc(eventId).update(finalUpdateData);
        print('Event updated: $eventId');
        fetchAllEvents(); // Refresh all event lists
        Get.snackbar('Success', 'Event updated successfully');
      } else {
        print('No changes detected for event: $eventId');
      }
    } catch (e) {
      print('Error updating event: $e');
      Get.snackbar('Error', 'Failed to update event');
    }
  }

  void toggleEventCompletion(String eventId, bool isCompleted) {
    updateEvent(eventId, {'isCompleted': isCompleted});
    fetchAllEvents(); // Refresh all lists after toggling completion
  }

  void fetchPendingEvents() {
    if (currentUser == null) return;

    eventsCollection
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .listen((querySnapshot) {
      pendingEvents.value = querySnapshot.docs
          .map((doc) => QuickEventModel.fromFirestore(doc))
          .toList();
      update();
    });
  }
  // upcoming

  void fetchUpcomingEvents() {
    if (currentUser == null) return;

    eventsCollection
        .where('isCompleted', isEqualTo: false)
        .where('date', isGreaterThanOrEqualTo: Timestamp.now())
        .snapshots()
        .listen((querySnapshot) {
      upcomingEvents.value = querySnapshot.docs
          .map((doc) => QuickEventModel.fromFirestore(doc))
          .toList();
      update();
    });
  }

  void updateUpcomingEvent(
      String eventId,
      String? newTitle,
      String? newDescription,
      DateTime? newDate,
      TimeOfDay? newStartTime,
      TimeOfDay? newEndTime,
      Color? newColor,
      bool? hasReminder,
      DateTime? reminderTime) async {
    // Fetch the current event data
    DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();
    Map<String, dynamic> currentData = eventDoc.data() as Map<String, dynamic>;

    Map<String, dynamic> updatedData = {};

    if (newTitle != null) updatedData['title'] = newTitle;
    if (newDescription != null) updatedData['description'] = newDescription;
    if (newColor != null) updatedData['color'] = newColor.value;
    if (hasReminder != null) updatedData['hasReminder'] = hasReminder;

    // Handle date and time updates
    DateTime currentDate = (currentData['date'] as Timestamp).toDate();
    DateTime? currentStartTime = currentData['startTime'] != null
        ? (currentData['startTime'] as Timestamp).toDate()
        : null;
    DateTime? currentEndTime = currentData['endTime'] != null
        ? (currentData['endTime'] as Timestamp).toDate()
        : null;

    if (newDate != null && newDate != currentDate) {
      updatedData['date'] = newDate;

      // Update start and end times if date changed
      if (currentStartTime != null) {
        updatedData['startTime'] = DateTime(newDate.year, newDate.month,
            newDate.day, currentStartTime.hour, currentStartTime.minute);
      }
      if (currentEndTime != null) {
        updatedData['endTime'] = DateTime(newDate.year, newDate.month,
            newDate.day, currentEndTime.hour, currentEndTime.minute);
      }
    }

    // Only update time if explicitly provided
    if (newStartTime != null) {
      updatedData['startTime'] = DateTime(
          newDate?.year ?? currentDate.year,
          newDate?.month ?? currentDate.month,
          newDate?.day ?? currentDate.day,
          newStartTime.hour,
          newStartTime.minute);
    }

    if (newEndTime != null) {
      updatedData['endTime'] = DateTime(
          newDate?.year ?? currentDate.year,
          newDate?.month ?? currentDate.month,
          newDate?.day ?? currentDate.day,
          newEndTime.hour,
          newEndTime.minute);
    }

    if (reminderTime != null) {
      updatedData['reminderTime'] = reminderTime;
    }

    await updateEvent(eventId, updatedData);
  }

  void deleteUpcomingEvent(String eventId) async {
    if (currentUser == null) return;
    try {
      await eventsCollection.doc(eventId).delete();
      fetchUpcomingEvents(); // Refresh the upcoming events list
    } catch (e) {
      print('Error deleting upcoming event: $e');
    }
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }

  //increase volume

  void updateGreeting() {
    final now = DateTime.now();
    if (now.hour >= 5 && now.hour < 12) {
      greeting.value = 'Good Morning';
    } else if (now.hour >= 12 && now.hour < 17) {
      greeting.value = 'Good Afternoon';
    } else {
      greeting.value = 'good evening.';
    }
  }

  // filter days for notification
  var selectedDays = <String>[].obs;

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }

  //get all goals

  void scheduleNotifications(String body, int interval, bool repeat) {
    AwesomeNotifications().cancelAll(); // Clear all existing notifications

    for (String day in selectedDays) {
      int weekday = _dayToWeekday(day);

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: weekday, // Unique id for each notification
          channelKey: 'quick_reminder',
          title: 'Scheduled Notification',
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          weekday: weekday,
          hour: 21, // Example time, adjust as needed
          minute: 0,
          second: 0,
          millisecond: 0,
          repeats: repeat,
        ),
      );
    }
  }

  int _dayToWeekday(String day) {
    switch (day) {
      case 'Monday':
        return DateTime.monday;
      case 'Tuesday':
        return DateTime.tuesday;
      case 'Wednesday':
        return DateTime.wednesday;
      case 'Thursday':
        return DateTime.thursday;
      case 'Friday':
        return DateTime.friday;
      case 'Saturday':
        return DateTime.saturday;
      case 'Sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  var chips = <ChipProperties>[
    ChipProperties(
        text: '15 min', fontColor: Colors.white, backgroundColor: Colors.grey),
    ChipProperties(
        text: '30 min', fontColor: Colors.white, backgroundColor: Colors.grey),
    ChipProperties(
        text: '1 hour', fontColor: Colors.white, backgroundColor: Colors.grey),
  ].obs;

  ChipProperties? originalChipProperties;
  var selectedChipIndex = 0.obs;
  var originalFontColor = Colors.white.obs;
  MaterialColor originalBackgroundColor = Colors.blue;

  void updateChipColor(
      int index, Color newFontColor, Color newBackgroundColor) {
    if (index >= 0 && index < chips.length) {
      if (selectedChipIndex.value == index) {
        // Revert to original properties
        chips[index].fontColor = originalFontColor.value;
        chips[index].backgroundColor = originalBackgroundColor;
        selectedChipIndex.value = -1; // Deselect the chip
      } else {
        if (selectedChipIndex.value != -1) {
          // Revert previously selected chip to original properties
          chips[selectedChipIndex.value].fontColor = originalFontColor.value;
          chips[selectedChipIndex.value].backgroundColor =
              originalBackgroundColor;
        }
        // Store the original properties of the new chip
        originalFontColor.value = chips[index].fontColor!;
        originalBackgroundColor = chips[index].backgroundColor as MaterialColor;

        // Update to new properties
        chips[index].fontColor = newFontColor;
        chips[index].backgroundColor = newBackgroundColor;
        selectedChipIndex.value = index; // Select the new chip
      }
      chips.refresh(); // Notify listeners
    }
  }

  Future<void> schedulePeriodicNotifications(
      String body, int interval, bool repeat) async {
    // Use WidgetsBinding to ensure we're on the main thread
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await AwesomeNotifications().requestPermissionToSendNotifications();

        int notificationId =
            DateTime.now().millisecondsSinceEpoch.remainder(100000);

        String localTimeZone =
            await AwesomeNotifications().getLocalTimeZoneIdentifier();
        DateTime now = DateTime.now();
        nextNotificationTime.value = now.add(Duration(minutes: interval));

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId,
            channelKey: 'quickschedule',
            title: 'DoBoara Reminder 📅',
            body: body,
            category: NotificationCategory.Reminder,
            notificationLayout: NotificationLayout.Default,
            criticalAlert: true,
            wakeUpScreen: true,
          ),
          schedule: NotificationInterval(
            interval: interval * 60, // Convert minutes to seconds
            timeZone: localTimeZone,
            repeats: repeat,
            preciseAlarm: true,
            allowWhileIdle: true,
          ),
        );

        print('Next notification time: ${nextNotificationTime.value}');
      } catch (e) {
        print('Error scheduling notification: $e');
        // You might want to show an error message to the user here
      }
    });
  }
   void calculateTriggerTime(int minutes) {
    DateTime now = DateTime.now();
    nextNotificationTime.value = now.add(Duration(minutes: minutes));
  }


  String getFormattedNextNotificationTime() {
    if (nextNotificationTime.value == null) {
      return 'Not set';
    }
    return DateFormat('MMM d, y HH:mm').format(nextNotificationTime.value!);
  }

  void toggleSwitch(bool value) {
    repeat.value = value;
  }

  void setText(String value) {
    text.value = value;
  }

  //cancel notification
  Future<void> cancelNotification() async {
    AwesomeNotifications().cancel(10);
  }

  //save data into firestore
  Future saveReminder(bool repeat) async {
    await remindersCollection.add({
      "reminder": reminderTextController.text,
      "time": timeSelected.value,
      "isReminderSet": true,
      "createdAt": FieldValue.serverTimestamp(),
      "repeat": repeat,
      "triggerTime": nextNotificationTime.value,
    }).then((_) {
      Get.back();
    });
  }

  //get goals from firestore

  String getReadableTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
