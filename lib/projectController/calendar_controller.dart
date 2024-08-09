import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/quick_event_model.dart';
import '../projectPages/page_two_calendar.dart';
import '../widgets/event_bottomSheet.dart';
import 'package:flutter/services.dart';

import 'profile_controller.dart';

class CalendarController extends GetxController {
  CalendarFormat calendarFormat = CalendarFormat.week;
 Rx<DateTime> focusedDay = DateTime.now().obs;
  Rx<DateTime> selectedDay = DateTime.now().obs;
  RxList<QuickEventModel> events = <QuickEventModel>[].obs;

  RxMap<DateTime, List<QuickEventModel>> eventsGrouped =
      <DateTime, List<QuickEventModel>>{}.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  CollectionReference get eventsCollection {
    return _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .collection('events');
  }

  @override
  void onInit() {
    super.onInit();
    fetchEvents(selectedDay.value);
  }


  bool isDateInPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool canAddEvent(DateTime day) {
    return !isDateInPast(day);
  }

  void setCalendarFormat(CalendarFormat format) {
    calendarFormat = format;
    update();
  }

  void setFocusedDay(DateTime day) {
    focusedDay.value = day;
    update();
  }

  int getEventCountForDay(DateTime day) {
    DateTime dateKey = DateTime(day.year, day.month, day.day);
    return eventsGrouped[dateKey]?.length ?? 0;
  }

  bool canAddMoreEvents(DateTime day) {
    return getEventCountForDay(day) < 10;
  }

  List<QuickEventModel> getEventsForDay(DateTime day) {
    DateTime dateKey = DateTime(day.year, day.month, day.day);
    List<QuickEventModel> dayEvents = eventsGrouped[dateKey] ?? [];
    print('Events for $dateKey: ${dayEvents.length}');
    return dayEvents;
  }

  bool canSelectDay(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return day.isAfter(today.subtract(Duration(days: 1))) ||
        isSameDay(day, today);
  }

  void setSelectedDay(DateTime day) {
    selectedDay.value = day;
    setFocusedDay(day);
    fetchEvents(day);
    update();
  }

  void toggleCalendarFormat() {
    calendarFormat = calendarFormat == CalendarFormat.month
        ? CalendarFormat.week
        : CalendarFormat.month;
    update();
  }

  void fetchEvents(DateTime day) {
    if (currentUser == null) return;
    events.clear();
    eventsGrouped.clear();

    DateTime startOfMonth = DateTime(day.year, day.month, 1);
    DateTime endOfMonth = DateTime(day.year, day.month + 1, 0, 23, 59, 59);

    eventsCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .snapshots()
        .listen((querySnapshot) {
      eventsGrouped.clear();
      events.clear(); // Clear the events list
      for (var doc in querySnapshot.docs) {
        QuickEventModel event = QuickEventModel.fromFirestore(doc);
        DateTime eventDate =
            DateTime(event.date.year, event.date.month, event.date.day);
        if (!eventsGrouped.containsKey(eventDate)) {
          eventsGrouped[eventDate] = [];
        }
        eventsGrouped[eventDate]!.add(event);
        events.add(event); // Add the event to the events list
      }
      print('Fetched events: ${eventsGrouped.length} days with events');
      update();
    });
  }

  bool hasEventsForDay(DateTime day) {
    DateTime dateKey = DateTime(day.year, day.month, day.day);
    return eventsGrouped[dateKey]?.isNotEmpty ?? false;
  }

  void deleteEvent(String eventId) async {
    if (currentUser == null) return;
    try {
      await eventsCollection.doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  void showEventBottomSheet(BuildContext context, {QuickEventModel? event}) {
    if (event == null) {
      if (!canAddEvent(selectedDay.value)) {
        Get.snackbar(
          'Cannot Add Event',
          'Events cannot be added to past dates.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (!canAddMoreEvents(selectedDay.value)) {
        Get.snackbar(
          'Event Limit Reached',
          'You can only add up to 10 events per day.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EventBottomSheet(
          event: event,
          initialDate: selectedDay.value,
          onSave: (title, description, date, TimeOfDay? startTime,
              TimeOfDay? endTime, color, hasReminder, reminderTime) {
            // Convert TimeOfDay to DateTime
            DateTime? startDateTime = startTime != null
                ? DateTime(date.year, date.month, date.day, startTime.hour,
                    startTime.minute)
                : null;
            DateTime? endDateTime = endTime != null
                ? DateTime(date.year, date.month, date.day, endTime.hour,
                    endTime.minute)
                : null;

            if (event == null) {
              if (canAddEvent(date)) {
                addEvent(title, description, date, startDateTime, endDateTime,
                    color, hasReminder, reminderTime, false);
              } else {
                Get.snackbar(
                  'Cannot Add Event',
                  'Events cannot be added to past dates.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            } else {
              updateEvent(event.id, title, description, date, startDateTime,
                  endDateTime, color, hasReminder, reminderTime, false);
            }
          },
        ),
      ),
    );
  }

  void addEvent(
      String title,
      String description,
      DateTime date,
      DateTime? startTime,
      DateTime? endTime,
      Color color,
      bool hasReminder,
      DateTime? reminderTime,
      bool isCompleted) async {
    if (currentUser == null) return;

    if (!canAddMoreEvents(date)) {
      Get.snackbar(
        'Event Limit Reached',
        'You can only add up to 10 events per day.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      DocumentReference docRef = await eventsCollection.add({
        'title': title,
        'description': description,
        'date': Timestamp.fromDate(date),
        'startTime':
            startTime != null ? Timestamp.fromDate(startTime) : DateTime.now(),
        'endTime': endTime != null ? Timestamp.fromDate(endTime) : null,
        'color': color.value,
        'hasReminder': hasReminder,
        'reminderTime':
            reminderTime != null ? Timestamp.fromDate(reminderTime) : null,
        'isCompleted': isCompleted,
        'createdAt': FieldValue.serverTimestamp(),
      });

      QuickEventModel newEvent = QuickEventModel(
        id: docRef.id,
        title: title,
        description: description,
        date: date,
        startTime: startTime,
        endTime: endTime,
        color: color,
        hasReminder: hasReminder,
        reminderTime: reminderTime,
        isCompleted: isCompleted,
        createdAt: DateTime.now(),
      );

      if (hasReminder && reminderTime != null) {
        await scheduleNotification(newEvent);
      }

      print('Event added for date: $date');
      fetchEvents(date);
      update();
    } catch (e) {
      print('Error adding event: $e');
    }
  }

  void updateEvent(
      String eventId,
      String newTitle,
      String newDescription,
      DateTime newDate,
      DateTime? newStartTime,
      DateTime? newEndTime,
      Color newColor,
      bool newHasReminder,
      DateTime? newReminderTime,
      bool isCompleted) async {
    if (currentUser == null) return;
    try {
      Map<String, dynamic> updateData = {
        'title': newTitle,
        'description': newDescription,
        'date': Timestamp.fromDate(newDate),
        'startTime':
            newStartTime != null ? Timestamp.fromDate(newStartTime) : null,
        'endTime': newEndTime != null ? Timestamp.fromDate(newEndTime) : null,
        'color': newColor.value,
        'hasReminder': newHasReminder,
        'reminderTime': newReminderTime != null
            ? Timestamp.fromDate(newReminderTime)
            : null,
        'isCompleted': isCompleted,
        // Note: We're not updating 'createdAt' here to preserve the original creation time
      };

      await eventsCollection.doc(eventId).update(updateData);

      QuickEventModel updatedEvent = QuickEventModel(
        id: eventId,
        title: newTitle,
        description: newDescription,
        date: newDate,
        startTime: newStartTime,
        endTime: newEndTime,
        color: newColor,
        hasReminder: newHasReminder,
        reminderTime: newReminderTime,
        isCompleted: isCompleted,
        createdAt:
            DateTime.now(), // This should ideally be fetched from Firestore
      );

      if (newHasReminder && newReminderTime != null) {
        await updateNotification(updatedEvent);
      } else {
        await cancelNotification(updatedEvent);
      }

      print('Event updated: $eventId');
      fetchEvents(newDate);
      update();
    } catch (e) {
      print('Error updating event: $e');
    }
  }

  void addToArchive(String eventId) async {
    if (currentUser == null) return;
    try {
      // Get the event document
      DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();

      // If the document exists
      if (eventDoc.exists) {
        // Create a new document in the archive collection
        await _firestore
            .collection('users')
            .doc(currentUser?.uid)
            .collection('archivedEvents')
            .doc(eventId)
            .set(eventDoc.data() as Map<String, dynamic>);

        // Delete the event from the active events collection
        await eventsCollection.doc(eventId).delete();

        // Refresh the events
        fetchEvents(selectedDay.value);
      }
    } catch (e) {
      print('Error archiving event: $e');
    }
  }

  //notifications
  Future<void> scheduleNotification(QuickEventModel event) async {
    if (!event.hasReminder || event.reminderTime == null) return;

    int notificationId = event.id.hashCode;

    // Create a DateTime that combines the event date and reminder time
    DateTime scheduledDate = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.reminderTime!.hour,
      event.reminderTime!.minute,
    );

    // If the scheduled time is in the past, don't schedule the notification
    if (scheduledDate.isBefore(DateTime.now())) {
      print('Reminder time is in the past. Notification not scheduled.');
      return;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'event_reminders',
        title: event.title,
        body: event.description,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
      ),
      schedule: NotificationCalendar(
        year: scheduledDate.year,
        month: scheduledDate.month,
        day: scheduledDate.day,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
        allowWhileIdle: true,
      ),
    );
    var profileController = Get.find<ProfileController>();
    profileController.fetchNotifications();

    print('Notification scheduled for: ${scheduledDate.toString()}');
  }

  Future<void> updateNotification(QuickEventModel event) async {
    // First, cancel the existing notification
    await cancelNotification(event);

    // Then, schedule a new notification
    await scheduleNotification(event);
  }

  Future<void> cancelNotification(QuickEventModel event) async {
    int notificationId = event.id.hashCode;
    await AwesomeNotifications().cancel(notificationId);
  }

  //
  Map<String, dynamic> getEventStatistics() {
    Map<String, int> eventCountByDay = {};
    Map<String, int> eventCountByMonth = {};
    int totalEvents = 0;

    eventsGrouped.forEach((date, events) {
      String dayKey = DateFormat('EEEE').format(date); // e.g., "Monday"
      String monthKey = DateFormat('MMMM').format(date); // e.g., "January"

      eventCountByDay[dayKey] = (eventCountByDay[dayKey] ?? 0) + events.length;
      eventCountByMonth[monthKey] =
          (eventCountByMonth[monthKey] ?? 0) + events.length;
      totalEvents += events.length;
    });

    return {
      'eventCountByDay': eventCountByDay,
      'eventCountByMonth': eventCountByMonth,
      'totalEvents': totalEvents,
    };
  }

  void toggleEventCompletion(String eventId) async {
    if (currentUser == null) return;
    try {
      DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();
      if (eventDoc.exists) {
        bool currentStatus = eventDoc.get('isCompleted') ?? false;
        bool newStatus = !currentStatus;
        await eventsCollection
            .doc(eventId)
            .update({'isCompleted': !currentStatus});
        if (newStatus) {
          HapticFeedback.mediumImpact();
        }
        fetchEvents(selectedDay.value);
      }
    } catch (e) {
      print('Error toggling event completion: $e');
    }
  }
}
