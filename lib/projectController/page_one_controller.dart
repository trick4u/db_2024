import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';

import '../app_routes.dart';
import '../models/goals_model.dart';
import '../models/quick_event_model.dart';
import '../models/reminder_model.dart';
import '../projectPages/awesome_noti.dart';
import '../services/app_theme.dart';
import '../services/notification_service.dart';
import '../services/work_manager.dart';
import '../widgets/quick_bottomsheet.dart';
import 'add_task_controller.dart';
import 'package:http/http.dart' as http;

import 'calendar_controller.dart';

class PageOneController extends GetxController {
  //variables

  // text field controller
  late TextEditingController reminderTextController = TextEditingController();
  RxInt timeSelected = 0.obs;
  var fireStoreInstance = FirebaseFirestore.instance;
  var repeat = false.obs;
  var text = "".obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxInt carouselPageIndex = 0.obs;
  final RxInt animationTrigger = 0.obs;

  final RxList<GoalsModel> allGoals = RxList<GoalsModel>([]);
  RxList<ReminderModel> allReminders = <ReminderModel>[].obs;
  //rx status
  Rx<RxStatus> goalsStatus = RxStatus.loading().obs;

  final greeting = RxString('');
  RxList<QuickEventModel> upcomingEvents = <QuickEventModel>[].obs;
  RxList<QuickEventModel> pendingEvents = <QuickEventModel>[].obs;
  RxList<QuickEventModel> completedEvents = <QuickEventModel>[].obs;
  User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxString selectedListType = ''.obs;
  Rx<DateTime?> nextNotificationTime = Rx<DateTime?>(null);
  final RxBool isGradientReversedReminder = false.obs;

  //more variables

  static const int MAX_REMINDERS = 10;
  static const int MIN_INTERVAL_MINUTES = 2;
  static const int MAX_REMINDER_TEXT_LENGTH = 70;
  static const int MAX_NOTIFICATION_TEXT_LENGTH = 50;
  static const int MAX_REPEAT_COUNT = 6;

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

  var isPlaying = false.obs;
  var currentStreamIndex = 0.obs;

  var isLoading = true.obs;
  final RxBool isGradientReversed = false.obs;

  late AudioPlayer _audioPlayer;
  final RxString selectedTile = ''.obs;
  final List<Map<String, dynamic>> items = [
    {'title': 'pomodoro', 'icon': FontAwesomeIcons.question},
    {'title': 'Take notes', 'icon': FontAwesomeIcons.noteSticky},
    {'title': 'All reminders', 'icon': FontAwesomeIcons.listCheck},
    {'title': 'Completed tasks', 'icon': FontAwesomeIcons.checkDouble},
    {'title': 'Upcoming', 'icon': FontAwesomeIcons.calendarDay},
    {'title': 'Vision', 'icon': FontAwesomeIcons.eye},
    {'title': 'Pending', 'icon': FontAwesomeIcons.clock},
    {'title': 'Add Reminders', 'icon': FontAwesomeIcons.plus},
  ];

  @override
  void onInit() {
    //   getAllGoals();
    updateAllReminders();
    _initializeSelectedTile();

    _audioPlayer = AudioPlayer();
    fetchAllEvents();
    fetchAllReminders();

    reminderTextController = TextEditingController();
    rescheduleAllReminders();

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

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  void toggleGradientDirectionReminder() {
    isGradientReversedReminder.toggle();
  }

  void toggleGradientDirection() {
    isGradientReversed.toggle();
  }

  void _initializeSelectedTile() {
    if (selectedTile.value.isEmpty) {
      final List<String> autoSelectTiles = [
        'upcoming',
        'pending',
        'completed tasks'
      ];
      final random = Random();
      selectedTile.value =
          autoSelectTiles[random.nextInt(autoSelectTiles.length)];
      setSelectedListType(selectedTile.value);
    }
  }

  void setSelectedTile(String tileTitle) {
    selectedTile.value = tileTitle;
  }

  void handleTileTap(
      int index, Function(String) onListTypeSelected, BuildContext context) {
    String tileTitle = items[index]['title']!.toLowerCase();
    selectedTile.value = tileTitle;
    if (tileTitle == 'pending' ||
        tileTitle == 'upcoming' ||
        tileTitle == 'completed tasks' ||
        tileTitle == 'all reminders') {
      onListTypeSelected(tileTitle);
    } else if (tileTitle == 'add reminders') {
      showQuickReminderBottomSheet(context);
    } else if (tileTitle == 'daily journal') {
      Get.toNamed(AppRoutes.JOURNAL);
    } else if (tileTitle == 'take notes') {
      Get.toNamed(AppRoutes.NOTETAKING);
    }
  }

  void showQuickReminderBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: QuickReminderBottomSheet(
            reminderController: this,
            appTheme: Get.find<AppTheme>(),
          ),
        );
      },
    ).then((_) {
      // Ensure the widget rebuilds after the bottom sheet is closed
      update();
    });
  }

  //for reminders
  Future<void> updateReminder(String reminderId, String newReminder,
      int newInterval, bool repeat) async {
    try {
      DateTime newTriggerTime =
          DateTime.now().add(Duration(minutes: newInterval));
      await remindersCollection.doc(reminderId).update({
        "reminder": newReminder,
        "interval": newInterval,
        "repeat": repeat,
        "triggerTime": newTriggerTime,
        "lastUpdated": FieldValue.serverTimestamp(),
      });

      // Reschedule the notification
      await AwesomeNotifications().cancel(reminderId.hashCode);
      await schedulePeriodicNotifications(
        newReminder,
        newInterval,
        repeat,
        notificationId: reminderId.hashCode,
        initialTriggerTime: newTriggerTime,
        documentId: reminderId,
      );

      print(
          'Reminder updated: $reminderId, New interval: $newInterval minutes, Repeat: $repeat');
      fetchAllReminders(); // Refresh the list
    } catch (e) {
      print('Error updating reminder: $e');
      Get.snackbar('Error', 'Failed to update reminder');
    }
  }

  void fetchAllReminders() {
    if (currentUser == null) return;

    remindersCollection.snapshots().listen((querySnapshot) {
      allReminders.value = querySnapshot.docs
          .map((doc) => ReminderModel.fromFirestore(doc))
          .toList();

      allReminders.sort((a, b) {
        // If both have createdAt, compare them
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        // If only a has createdAt, it should come first
        else if (a.createdAt != null) {
          return -1;
        }
        // If only b has createdAt, it should come first
        else if (b.createdAt != null) {
          return 1;
        }
        // If neither has createdAt, maintain their original order
        else {
          return 0;
        }
      });

      update();
    });
  }

  void scheduleReminderRemoval(String documentId) {
    // Schedule the removal of the reminder after a delay
    Future.delayed(Duration(minutes: 5), () async {
      await deleteReminder(documentId);
      print('Non-repeating reminder removed after delay: $documentId');
    });
  }

  Future<void> deleteReminder(String reminderId) async {
    if (currentUser == null) return;
    try {
      // Fetch the reminder document
      DocumentSnapshot reminderDoc =
          await remindersCollection.doc(reminderId).get();
      ReminderModel reminder = ReminderModel.fromFirestore(reminderDoc);

      // Attempt to cancel the notification
      try {
        await cancelNotificationForReminder(reminder.notificationId);
        print('Notification canceled successfully for reminder: $reminderId');
      } catch (e) {
        print(
            'Warning: Failed to cancel notification for reminder: $reminderId. Error: $e');
      }

      // Delete the reminder from Firestore
      await remindersCollection.doc(reminderId).delete();
      allReminders.removeWhere((r) => r.id == reminderId);

      Get.snackbar('Success', 'Reminder deleted successfully');
      fetchAllReminders();
      update();
    } catch (e) {
      print('Error deleting reminder: $e');
      Get.snackbar('Error', 'Failed to delete reminder');
    }
  }

  Future<void> cancelNotificationForReminder(int? notificationId) async {
    await WorkmanagerNotificationService.cancelNotification(
        notificationId.toString(), 'page_one');
    if (notificationId == null) {
      print('No notification ID provided');
      return;
    }
    try {
      await AwesomeNotifications().cancel(notificationId);
      print('Notification cancellation requested for ID: $notificationId');
    } catch (e) {
      print('Error canceling notification: $e');
      throw e; // Re-throw the error to be caught in deleteReminder
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

  void toggleEventCompletion(String eventId, bool isCompleted) async {
    try {
      await updateEvent(eventId, {'isCompleted': isCompleted});

      if (isCompleted) {
        // Play sound when marking as complete
        await _audioPlayer.setAsset('assets/success.mp3');
        await _audioPlayer.play();
      }

      fetchAllEvents(); // Refresh all lists after toggling completion
    } catch (e) {
      print('Error toggling event completion: $e');
      Get.snackbar('Error', 'Failed to update event completion status');
    }
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

  Future<void> updateNextTriggerTime(String reminderId) async {
    try {
      DocumentSnapshot reminderDoc =
          await remindersCollection.doc(reminderId).get();
      ReminderModel reminder = ReminderModel.fromFirestore(reminderDoc);

      if (reminder.repeat &&
          reminder.triggerTime != null &&
          reminder.triggerTime!.isBefore(DateTime.now())) {
        DateTime nextTriggerTime = reminder.triggerTime!;
        int intervalMinutes = reminder.time;
        while (nextTriggerTime.isBefore(DateTime.now())) {
          nextTriggerTime =
              nextTriggerTime.add(Duration(minutes: intervalMinutes));
        }

        await remindersCollection.doc(reminderId).update({
          'triggerTime': nextTriggerTime,
        });
        await WorkmanagerNotificationService.cancelNotification(
            reminder.notificationId?.toString() ?? reminderId, 'page_one');

        await AwesomeNotifications().cancel(reminder.notificationId ?? 0);
        await schedulePeriodicNotifications(
            reminder.reminder, intervalMinutes, reminder.repeat,
            notificationId:
                reminder.notificationId ?? reminder.reminder.hashCode,
            initialTriggerTime: nextTriggerTime,
            documentId: reminderId // Add this line to pass the documentId
            );

        print(
            'Updated next trigger time for reminder: $reminderId, Next trigger: $nextTriggerTime, Interval: $intervalMinutes minutes');
      }
    } catch (e) {
      print('Error updating next trigger time: $e');
    }
  }

  Future<void> schedulePeriodicNotifications(
    String body,
    int interval,
    bool repeat, {
    int? notificationId,
    DateTime? initialTriggerTime,
    required String documentId,
    int triggerCount = 0,
  }) async {
    try {
      notificationId ??= body.hashCode;
      DateTime scheduledDate =
          initialTriggerTime ?? DateTime.now().add(Duration(minutes: interval));

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'quickschedule',
          title: 'DoBoard Reminder 📅',
          body: body,
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
          criticalAlert: true,
          wakeUpScreen: true,
          autoDismissible: false,
          payload: {
            'repeat': repeat.toString(),
            'interval': interval.toString(),
            'documentId': documentId,
            'triggerCount': triggerCount.toString(),
          },
        ),
        schedule: NotificationCalendar.fromDate(date: scheduledDate),
        actionButtons: [
          NotificationActionButton(
            key: 'MARK_DONE',
            label: 'Mark as Done',
          ),
          NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
            actionType: ActionType.DismissAction,
          ),
        ],
      );
      Map<String, dynamic> notificationData = {
        'id': notificationId,
        'channelKey': 'quickschedule',
        'title': 'DoBoard Reminder 📅',
        'body': body,
        'scheduledTime': scheduledDate.toIso8601String(),
        'repeat': repeat,
        'interval': interval,
        'documentId': documentId,
        'triggerCount': triggerCount,
        'source': 'page_one',
      };

      await WorkmanagerNotificationService.scheduleNotification(
          notificationData);

      print(
          'Scheduled notification with ID: $notificationId for time: $scheduledDate, Repeat: $repeat, DocumentID: $documentId, TriggerCount: $triggerCount');

      // Update the Firestore document with the scheduled time and trigger count
      await updateReminderTriggerTime(documentId, scheduledDate, triggerCount);
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  //   Future<void> scheduleNextNotification(int notificationId, String body, int interval, DateTime lastTriggerTime, String documentId) async {
  //   DateTime nextTriggerTime = lastTriggerTime.add(Duration(minutes: interval));

  //   await AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //       id: notificationId,
  //       channelKey: 'quickschedule',
  //       title: 'DoBoard Reminder 📅',
  //       body: body,
  //       category: NotificationCategory.Reminder,
  //       notificationLayout: NotificationLayout.Default,
  //       criticalAlert: true,
  //       wakeUpScreen: true,
  //       payload: {
  //         'repeat': 'true',
  //         'interval': interval.toString(),
  //         'documentId': documentId,
  //       },
  //     ),
  //     schedule: NotificationCalendar(
  //       year: nextTriggerTime.year,
  //       month: nextTriggerTime.month,
  //       day: nextTriggerTime.day,
  //       hour: nextTriggerTime.hour,
  //       minute: nextTriggerTime.minute,
  //       second: 0,
  //       millisecond: 0,
  //       repeats: false,
  //       preciseAlarm: true,
  //       allowWhileIdle: true,
  //     ),
  //   );

  //   print('Scheduled next notification with ID: $notificationId for time: $nextTriggerTime, DocumentID: $documentId');

  //   // Update the trigger time in Firestore
  //   await updateReminderTriggerTime(documentId, nextTriggerTime);
  // }

  Future<void> updateReminderTriggerTime(
      String documentId, DateTime triggerTime, int triggerCount) async {
    try {
      await remindersCollection.doc(documentId).update({
        'triggerTime': triggerTime,
        'lastUpdated': FieldValue.serverTimestamp(),
        'triggerCount': triggerCount,
      });
      print(
          'Updated trigger time for document: $documentId to $triggerTime, TriggerCount: $triggerCount');
    } catch (e) {
      print('Error updating reminder trigger time: $e');
    }
  }

  void updateAllReminders() {
    for (var reminder in allReminders) {
      updateNextTriggerTime(reminder.id ?? "");
    }
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
  Future<void> saveReminder(bool repeat) async {
    int notificationId = reminderTextController.text.hashCode;
    DateTime triggerTime = nextNotificationTime.value ??
        DateTime.now().add(Duration(minutes: timeSelected.value));

    DocumentReference docRef = await remindersCollection.add({
      "reminder": reminderTextController.text,
      "time": timeSelected.value,
      "isReminderSet": true,
      "createdAt": FieldValue.serverTimestamp(),
      "repeat": repeat,
      "triggerTime": triggerTime,
      "notificationId": notificationId,
    });

    String documentId = docRef.id;

    await schedulePeriodicNotifications(
      reminderTextController.text,
      timeSelected.value,
      repeat,
      notificationId: notificationId,
      initialTriggerTime: triggerTime,
      documentId: documentId,
    );

    Get.back();
    setSelectedTile('all reminders');
    setSelectedListType('all reminders');
  }

  Future<void> onNotificationDisplayed(String documentId) async {
    try {
      DocumentSnapshot doc = await remindersCollection.doc(documentId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        int repeatCount = (data['repeatCount'] ?? 0) + 1;
        bool repeat = data['repeat'] ?? false;

        if (repeat && repeatCount >= MAX_REPEAT_COUNT) {
          await deleteReminder(documentId);
          print(
              'Repeating reminder removed after $MAX_REPEAT_COUNT displays: $documentId');
        } else {
          await remindersCollection.doc(documentId).update({
            'repeatCount': repeatCount,
          });
          print('Updated repeat count for reminder $documentId: $repeatCount');
        }
      }
    } catch (e) {
      print('Error in onNotificationDisplayed: $e');
    }
  }

  Future<String?> createReminder(
      String reminder, int interval, bool repeat) async {
    if (allReminders.length >= MAX_REMINDERS) {
      Get.snackbar('Limit Reached', 'You can only have up to 10 reminders.');
      return null;
    }

    DateTime triggerTime = await _getNextAvailableTriggerTime(interval);

    DocumentReference docRef = await remindersCollection.add({
      "reminder": reminder,
      "interval": interval,
      "isReminderSet": true,
      "createdAt": FieldValue.serverTimestamp(),
      "repeat": repeat,
      "triggerTime": triggerTime,
      "notificationId": reminder.hashCode,
    });

    await schedulePeriodicNotifications(
      reminder,
      interval,
      repeat,
      notificationId: reminder.hashCode,
      initialTriggerTime: triggerTime,
      documentId: docRef.id,
    );

    print(
        'Created reminder with ID: ${docRef.id}, Interval: $interval minutes, TriggerTime: $triggerTime');
    return docRef.id;
  }

  Future<DateTime> _getNextAvailableTriggerTime(int interval) async {
    DateTime now = DateTime.now();
    DateTime proposedTime = now.add(Duration(minutes: interval));

    QuerySnapshot existingReminders = await remindersCollection
        .where('triggerTime', isGreaterThanOrEqualTo: now)
        .orderBy('triggerTime')
        .get();

    List<DateTime> existingTimes = existingReminders.docs
        .map((doc) => (doc['triggerTime'] as Timestamp).toDate())
        .toList();

    existingTimes.sort();

    for (DateTime existingTime in existingTimes) {
      if (proposedTime.difference(existingTime).inMinutes.abs() < 2) {
        proposedTime = existingTime.add(Duration(minutes: 2));
      }
    }

    // Ensure the proposed time is at least 2 minutes from now
    if (proposedTime.difference(now).inMinutes < 2) {
      proposedTime = now.add(Duration(minutes: 2));
    }

    return proposedTime;
  }

  Future<void> rescheduleExistingReminder(String documentId) async {
    try {
      DocumentSnapshot reminderDoc =
          await remindersCollection.doc(documentId).get();
      if (reminderDoc.exists) {
        Map<String, dynamic> data = reminderDoc.data() as Map<String, dynamic>;

        await schedulePeriodicNotifications(
          data['reminder'],
          data['time'],
          data['repeat'],
          notificationId: data['notificationId'],
          initialTriggerTime: (data['triggerTime'] as Timestamp).toDate(),
          documentId: documentId,
        );
      }
    } catch (e) {
      print('Error rescheduling existing reminder: $e');
    }
  }

  // Call this method when the app starts or when you need to ensure all reminders are properly scheduled
  Future<void> rescheduleAllReminders() async {
    try {
      QuerySnapshot reminders = await remindersCollection.get();
      for (var doc in reminders.docs) {
        await rescheduleExistingReminder(doc.id);
      }
    } catch (e) {
      print('Error rescheduling all reminders: $e');
    }
  }

  //get goals from firestore

  String getReadableTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}

extension NotificationSchedulingExtension on PageOneController {
  Map<String, dynamic> robustSanitizeEventData(Map<String, dynamic> data) {
    Map<String, dynamic> sanitizedData = {};

    data.forEach((key, value) {
      if (value != null) {
        if (value is DateTime) {
          sanitizedData[key] = Timestamp.fromDate(value);
        } else if (key == 'startTime' ||
            key == 'endTime' ||
            key == 'reminderTime') {
          if (value is DateTime) {
            sanitizedData[key] = Timestamp.fromDate(value);
          } else if (value is Timestamp) {
            sanitizedData[key] = value;
          }
          // If it's neither DateTime nor Timestamp, we don't include it
        } else {
          sanitizedData[key] = value;
        }
      }
    });

    return sanitizedData;
  }

  Future<void> robustUpdateEventWithErrorHandling(
      String eventId, Map<String, dynamic> updatedData) async {
    try {
      Map<String, dynamic> sanitizedData = robustSanitizeEventData(updatedData);

      // Fetch the current event data
      DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();
      Map<String, dynamic> currentData =
          eventDoc.data() as Map<String, dynamic>;

      // Merge the sanitized data with the current data
      Map<String, dynamic> mergedData = {...currentData, ...sanitizedData};

      // Update the event
      await eventsCollection.doc(eventId).update(mergedData);

      // Recreate the QuickEventModel
      QuickEventModel updatedEvent = QuickEventModel.fromFirestore(
          await eventsCollection.doc(eventId).get());

      // Handle notification
      if (updatedEvent.hasReminder && updatedEvent.reminderTime != null) {
        await scheduleEventNotification(updatedEvent);
      } else {
        await cancelEventNotification(updatedEvent);
      }

      print('Event updated successfully: $eventId');
    } catch (e) {
      print('Error updating event: $e');
      Get.snackbar('Error', 'Failed to update event. Please try again.');
    }
  }

  Future<void> scheduleEventNotification(QuickEventModel event) async {
    final calendarController = Get.find<CalendarController>();
    await calendarController.scheduleNotification(event);
  }

  Future<void> cancelEventNotification(QuickEventModel event) async {
    final calendarController = Get.find<CalendarController>();
    await calendarController.cancelNotification(event);
  }

  Map<String, dynamic> sanitizeEventData(Map<String, dynamic> data) {
    Map<String, dynamic> sanitizedData = {};

    data.forEach((key, value) {
      if (value != null) {
        if (value is DateTime) {
          sanitizedData[key] = Timestamp.fromDate(value);
        } else if (key == 'startTime' ||
            key == 'endTime' ||
            key == 'reminderTime') {
          if (value is DateTime) {
            sanitizedData[key] = Timestamp.fromDate(value);
          }
        } else {
          sanitizedData[key] = value;
        }
      }
    });

    return sanitizedData;
  }

  Future<void> updateEventWithErrorHandling(
      String eventId, Map<String, dynamic> updatedData) async {
    try {
      Map<String, dynamic> sanitizedData = sanitizeEventData(updatedData);
      await updateEvent(eventId, sanitizedData);

      // Fetch the updated event
      DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();
      QuickEventModel updatedEvent = QuickEventModel.fromFirestore(eventDoc);

      // Schedule or cancel notification based on the updated event data
      await scheduleEventNotification(updatedEvent);

      print('Event updated successfully: $eventId');
    } catch (e) {
      print('Error updating event: $e');
      // Here you can add more error handling, such as showing a snackbar to the user
      Get.snackbar('Error', 'Failed to update event. Please try again.');
    }
  }


  Future<void> updateEventWithNotification(
      String eventId, Map<String, dynamic> updatedData) async {
    await updateEvent(eventId, updatedData);

    // Fetch the updated event
    DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();
    QuickEventModel updatedEvent = QuickEventModel.fromFirestore(eventDoc);

    // Schedule or cancel notification based on the updated event data
    await scheduleEventNotification(updatedEvent);
  }
}
