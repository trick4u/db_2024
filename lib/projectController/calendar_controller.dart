import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/quick_event_model.dart';
import '../projectPages/page_two_calendar.dart';
import '../services/pexels_service.dart';
import '../services/toast_util.dart';
import '../services/work_manager.dart';
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
  RxString backgroundImageUrl = ''.obs;
  final PexelsService _pexelsService = PexelsService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  late AudioPlayer _audioPlayer = AudioPlayer();

  RxBool isLoading = true.obs;
  RxBool hasError = false.obs;
  RxInt imageFetchCount = 0.obs;
  RxString lastFetchDate = ''.obs;

  CollectionReference get eventsCollection {
    return _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .collection('events');
  }

  //expansion
  RxMap<String, bool> expandedEvents = <String, bool>{}.obs;
  // Rx<VideoPlayerController?> backgroundVideoController =
  //     Rx<VideoPlayerController?>(null);
  RxString backgroundVideoUrl = ''.obs;

  RxInt backgroundChangeCount = 0.obs;
  RxBool isChangingBackground = false.obs;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();
    loadInitialData();
    fetchRandomBackgroundImage();
    loadImageFetchData();
    rescheduleNotifications();
    loadSavedBackgroundImage();
    loadBackgroundChangeCount();
    //  fetchRandomBackgroundVideo();
  }

  @override
  void onClose() {
    // backgroundVideoController.value?.dispose();
    super.onClose();
  }

  // Future<void> fetchRandomBackgroundVideo() async {
  //   try {
  //     final videoUrl = await _pexelsService.getRandomVideoUrl();
  //     if (videoUrl.isNotEmpty) {
  //       backgroundVideoUrl.value = videoUrl;
  //       await loadVideoPlayer(videoUrl);
  //     } else {
  //       print('Received empty video URL, loading fallback');
  //       await loadFallbackVideo();
  //     }
  //   } catch (e) {
  //     print('Error fetching random background video: $e');
  //     await loadFallbackVideo();
  //   }
  // }

  // Future<void> loadVideoPlayer(String url) async {
  //   if (backgroundVideoController.value != null) {
  //     await backgroundVideoController.value!.dispose();
  //   }

  //   try {
  //     backgroundVideoController.value =
  //         VideoPlayerController.networkUrl(Uri.parse(url));
  //     await backgroundVideoController.value!.initialize();
  //     backgroundVideoController.value!.setLooping(true);
  //     backgroundVideoController.value!.play();
  //     backgroundVideoController.value!.setVolume(0);

  //     update();
  //   } catch (e) {
  //     print('Error initializing video player: $e');
  //     await loadFallbackVideo();
  //   }
  // }

  // Future<void> loadFallbackVideo() async {
  //   // Load a fallback video or image
  //   // This could be a local asset or a reliable remote URL
  //   String fallbackUrl = 'https://www.pexels.com/video/hot-tea-in-mug-14319069/';
  //   try {
  //     await loadVideoPlayer(fallbackUrl);
  //   } catch (e) {
  //     print('Error loading fallback video: $e');
  //     // If even the fallback fails, we'll just leave the controller as null
  //     backgroundVideoController.value = null;
  //     update();
  //   }
  // }

  Future<void> loadBackgroundChangeCount() async {
    final prefs = await SharedPreferences.getInstance();
    backgroundChangeCount.value = prefs.getInt('background_change_count') ?? 0;
  }

  Future<void> rescheduleNotifications() async {
    if (currentUser == null) return;

    QuerySnapshot eventSnapshot =
        await eventsCollection.where('hasReminder', isEqualTo: true).get();

    for (var doc in eventSnapshot.docs) {
      QuickEventModel event = QuickEventModel.fromFirestore(doc);
      if (event.reminderTime != null &&
          event.reminderTime!.isAfter(DateTime.now())) {
        await scheduleNotification(event);
      }
    }
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      await fetchEvents(selectedDay.value);
      await fetchRandomBackgroundImage();
      await loadSavedBackgroundImage();
    } catch (e) {
      print('Error loading initial data: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadImageFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    imageFetchCount.value = prefs.getInt('image_fetch_count') ?? 0;
    lastFetchDate.value = prefs.getString('last_fetch_date') ?? '';

    // Reset count if it's a new day
    if (lastFetchDate.value !=
        DateFormat('yyyy-MM-dd').format(DateTime.now())) {
      imageFetchCount.value = 0;
      lastFetchDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await prefs.setInt('image_fetch_count', 0);
      await prefs.setString('last_fetch_date', lastFetchDate.value);
    }
  }

  Future<void> fetchRandomBackgroundImage() async {
    if (isChangingBackground.value) {
      return;
    }

    isChangingBackground.value = true;

    try {
      final imageUrl = await _pexelsService.getRandomImageUrl();
      if (imageUrl.isNotEmpty) {
        backgroundImageUrl.value = imageUrl;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('background_image_url', imageUrl);

        backgroundChangeCount.value++;
        await prefs.setInt(
            'background_change_count', backgroundChangeCount.value);

        update(); // Trigger UI update
      } else {
        throw Exception('Received empty image URL');
      }
    } catch (e) {
      print('Error fetching random background image: $e');
      await loadSavedBackgroundImage();
    } finally {
      isChangingBackground.value = false;
    }
  }

  Future<void> loadSavedBackgroundImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImageUrl = prefs.getString('background_image_url');
    if (savedImageUrl != null && savedImageUrl.isNotEmpty) {
      backgroundImageUrl.value = savedImageUrl;
    } else {
      // Use a default image URL if no saved image is available
      backgroundImageUrl.value =
          'https://cdn.pixabay.com/photo/2024/04/09/22/28/trees-8686902_1280.jpg';
    }
  }

  //expansion
  void toggleEventExpansion(String eventId) {
    if (!expandedEvents.containsKey(eventId)) {
      expandedEvents[eventId] = false;
    }
    expandedEvents[eventId] = !expandedEvents[eventId]!;
    update();
  }

  // Add this new method to check if an event is expanded
  bool isEventExpanded(String eventId) {
    return expandedEvents[eventId] ?? false;
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

  Future<void> fetchEvents(DateTime day) async {
    if (currentUser == null) {
      hasError.value = true;
      return;
    }

    try {
      DateTime startOfMonth = DateTime(day.year, day.month, 1);
      DateTime endOfMonth = DateTime(day.year, day.month + 1, 0, 23, 59, 59);

      QuerySnapshot querySnapshot = await eventsCollection
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      Map<DateTime, List<QuickEventModel>> newEventsGrouped = {};
      List<QuickEventModel> newEvents = [];

      for (var doc in querySnapshot.docs) {
        QuickEventModel event = QuickEventModel.fromFirestore(doc);
        DateTime eventDate =
            DateTime(event.date.year, event.date.month, event.date.day);

        if (!newEventsGrouped.containsKey(eventDate)) {
          newEventsGrouped[eventDate] = [];
        }
        newEventsGrouped[eventDate]!.add(event);
        newEvents.add(event);
      }

      eventsGrouped.value = newEventsGrouped;
      events.value = newEvents;

      update();
    } catch (e) {
      print('Error fetching events: $e');
      hasError.value = true;
    }
  }

  bool hasEventsForDay(DateTime day) {
    DateTime dateKey = DateTime(day.year, day.month, day.day);
    return eventsGrouped[dateKey]?.isNotEmpty ?? false;
  }

  Future<void> deleteEvent(String eventId) async {
    if (currentUser == null) return;
    try {
      // First, fetch the event data
      DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();
      if (eventDoc.exists) {
        QuickEventModel event = QuickEventModel.fromFirestore(eventDoc);

        // Cancel the notification if it exists
        await cancelNotification(event);

        // Remove the event from the local lists immediately
        events.removeWhere((e) => e.id == eventId);

        // Update the eventsGrouped map
        DateTime eventDate =
            DateTime(event.date.year, event.date.month, event.date.day);
        if (eventsGrouped.containsKey(eventDate)) {
          eventsGrouped[eventDate]!.removeWhere((e) => e.id == eventId);
          if (eventsGrouped[eventDate]!.isEmpty) {
            eventsGrouped.remove(eventDate);
          }
        }

        // Delete the event from Firestore
        await eventsCollection.doc(eventId).delete();

        print('Event deleted: $eventId');
        update(); // Trigger UI update
      }
    } catch (e) {
      print('Error deleting event: $e');
      ToastUtil.showToast('Error', 'Failed to delete event');
    }
  }

  void showEventBottomSheet(BuildContext context, {QuickEventModel? event}) {
    if (event == null) {
      if (!canAddEvent(selectedDay.value)) {
        ToastUtil.showToast(
          'Cannot Add Event',
          'Events cannot be added to past dates.',
        
        );
        return;
      }
      if (!canAddMoreEvents(selectedDay.value)) {
        ToastUtil.showToast(
          'Event Limit Reached',
          'You can only add up to 10 events per day.',
        
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
          onSave: (title,
              description,
              date,
              TimeOfDay? startTime,
              TimeOfDay? endTime,
              color,
              hasReminder,
              reminderTime,
              repetition) {
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
                    color, hasReminder, reminderTime, false, repetition);
              } else {
                ToastUtil.showToast(
                  'Cannot Add Event',
                  'Events cannot be added to past dates.',
                
                );
              }
            } else {
              updateEvent(
                event.id,
                title,
                description,
                date,
                startDateTime,
                endDateTime,
                color,
                hasReminder,
                reminderTime,
                repetition,
              );
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
      bool isCompleted,
      String? repetition) async {
    if (currentUser == null) return;

    if (!canAddMoreEvents(date)) {
      ToastUtil.showToast(
        'Event Limit Reached',
        'You can only add up to 10 events per day.',
      
      );
      return;
    }

    try {
      List<DateTime> repetitionDates = _getRepetitionDates(date, repetition);

      for (DateTime eventDate in repetitionDates) {
        QuickEventModel newEvent = QuickEventModel(
          id: '', // This will be set by Firestore
          title: title,
          description: description,
          date: eventDate,
          startTime: startTime,
          endTime: endTime,
          color: color,
          hasReminder: hasReminder,
          reminderTime: reminderTime,
          isCompleted: isCompleted,
          createdAt: DateTime.now(),
          repetition: repetition,
        );

        DocumentReference docRef =
            await eventsCollection.add(newEvent.toFirestore());
        newEvent = newEvent.copyWith(id: docRef.id);

        if (hasReminder && reminderTime != null) {
          await scheduleNotification(newEvent);
        }

        print('Event added for date: $eventDate');
      }

      fetchEvents(date);
      update();
    } catch (e) {
      print('Error adding event: $e');
    }
  }

  List<DateTime> _getRepetitionDates(DateTime initialDate, String? repetition) {
    List<DateTime> dates = [initialDate];

    if (repetition == 'week') {
      final endOfWeek =
          initialDate.add(Duration(days: 7 - initialDate.weekday));
      for (var i = 1; i < 7; i++) {
        final nextDate = initialDate.add(Duration(days: i));
        if (!nextDate.isAfter(endOfWeek)) {
          dates.add(nextDate);
        }
      }
    } else if (repetition == 'month') {
      final lastDayOfMonth =
          DateTime(initialDate.year, initialDate.month + 1, 0);
      for (var i = 1; i <= lastDayOfMonth.day - initialDate.day; i++) {
        dates.add(initialDate.add(Duration(days: i)));
      }
    }

    return dates;
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
      String? newRepetition) async {
    if (currentUser == null) return;
    try {
      DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();
      Map<String, dynamic> currentData =
          eventDoc.data() as Map<String, dynamic>;

      bool wasCompleted = currentData['isCompleted'] ?? false;
      Timestamp? completedAt = currentData['completedAt'] as Timestamp?;

      Map<String, dynamic> updateData = {};
      Map<String, dynamic> changeLog = {};

      void addToUpdateAndLog(String field, dynamic newValue, dynamic oldValue) {
        if (newValue != oldValue) {
          updateData[field] = newValue;
          changeLog[field] = {'old': oldValue, 'new': newValue};
        }
      }

      addToUpdateAndLog('title', newTitle, currentData['title']);
      addToUpdateAndLog(
          'description', newDescription, currentData['description']);
      addToUpdateAndLog(
          'date', Timestamp.fromDate(newDate), currentData['date']);
      addToUpdateAndLog('color', newColor.value, currentData['color']);
      addToUpdateAndLog(
          'hasReminder', newHasReminder, currentData['hasReminder']);
      addToUpdateAndLog('repetition', newRepetition, currentData['repetition']);

      if (newStartTime != null) {
        addToUpdateAndLog('startTime', Timestamp.fromDate(newStartTime),
            currentData['startTime']);
      }
      if (newEndTime != null) {
        addToUpdateAndLog(
            'endTime', Timestamp.fromDate(newEndTime), currentData['endTime']);
      }
      if (newReminderTime != null) {
        addToUpdateAndLog('reminderTime', Timestamp.fromDate(newReminderTime),
            currentData['reminderTime']);
      }

      if (updateData.isNotEmpty) {
        // If the event was completed and is being edited, add a flag
        if (wasCompleted && completedAt != null) {
          updateData['editedAfterCompletion'] = true;
          // Add the change log to Firestore
          updateData['changeLog'] = FieldValue.arrayUnion([
            {'timestamp': Timestamp.now(), 'changes': changeLog}
          ]);
        }

        await eventsCollection.doc(eventId).update(updateData);

        QuickEventModel updatedEvent = QuickEventModel(
          id: eventId,
          title: newTitle,
          description: newDescription,
          date: newDate,
          startTime: newStartTime ??
              (currentData['startTime'] as Timestamp?)?.toDate(),
          endTime:
              newEndTime ?? (currentData['endTime'] as Timestamp?)?.toDate(),
          color: newColor,
          hasReminder: newHasReminder,
          reminderTime: newReminderTime ??
              (currentData['reminderTime'] as Timestamp?)?.toDate(),
          isCompleted: wasCompleted,
          createdAt: (currentData['createdAt'] as Timestamp).toDate(),
          editedAfterCompletion:
              wasCompleted && updateData['editedAfterCompletion'] == true,
          completedAt: completedAt?.toDate(),
        );

        if (newHasReminder &&
            updatedEvent.reminderTime != null &&
            !updatedEvent.isCompleted!) {
          await updateNotification(updatedEvent);
        } else {
          await cancelNotification(updatedEvent);
        }

        print('Event updated: $eventId');
        fetchEvents(newDate);
        update();
      } else {
        print('No changes detected for event: $eventId');
      }
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
  Future<void> markNotificationAsDisplayed(int notificationId) async {
    try {
      // Find the event with this notification ID
      QuerySnapshot eventQuery = await eventsCollection
          .where('notificationId', isEqualTo: notificationId)
          .limit(1)
          .get();

      if (eventQuery.docs.isNotEmpty) {
        String eventId = eventQuery.docs.first.id;
        DateTime now = DateTime.now();

        await eventsCollection.doc(eventId).update({
          'lastNotificationDisplayed': Timestamp.fromDate(now),
        });

        // Update the local event model
        int index = events.indexWhere((e) => e.id == eventId);
        if (index != -1) {
          events[index] = events[index].copyWith(
            lastNotificationDisplayed: now,
          );

          // Update the eventsGrouped map
          DateTime eventDate = DateTime(events[index].date.year,
              events[index].date.month, events[index].date.day);
          int groupIndex =
              eventsGrouped[eventDate]?.indexWhere((e) => e.id == eventId) ??
                  -1;
          if (groupIndex != -1) {
            eventsGrouped[eventDate]![groupIndex] = events[index];
          }
        }

        print('Marked notification as displayed for event: $eventId');
        update(); // This will trigger a rebuild of the UI
      } else {
        print('No event found for notification ID: $notificationId');
      }
    } catch (e) {
      print('Error marking notification as displayed: $e');
    }
  }

  Future<void> scheduleNotification(QuickEventModel event) async {
    if (!event.hasReminder || event.reminderTime == null) {
      print('Reminder not set for event: ${event.id}');
      return;
    }

    int notificationId = event.id.hashCode;

    DateTime scheduledDate = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.reminderTime!.hour,
      event.reminderTime!.minute,
    );

    if (scheduledDate.isBefore(DateTime.now())) {
      print(
          'Reminder time is in the past for event: ${event.id}. Notification not scheduled.');
      return;
    }

    try {
      // Cancel any existing notification for this event
      await AwesomeNotifications().cancel(notificationId);
      print('Cancelled existing notification for event: ${event.id}');

      bool success = await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'quickschedule',
          title: 'Event Reminder',
          body: event.title,
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
          criticalAlert: true,
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
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );

      if (success) {
        print(
            'Scheduled notification with ID: $notificationId for event: ${event.id} at time: $scheduledDate');
        await WorkmanagerNotificationService.cancelNotification(
            event.id, 'calendar');
        print('Cancelled existing notification for event: ${event.id}');

        Map<String, dynamic> notificationData = {
          'id': notificationId,
          'channelKey': 'quickschedule',
          'title': 'Event Reminder',
          'body': event.title,
          'scheduledTime': scheduledDate.toIso8601String(),
          'source': 'calendar',
        };

        await WorkmanagerNotificationService.scheduleNotification(
            notificationData);
        // Update the event in Firestore
        await eventsCollection.doc(event.id).update({
          'notificationId': notificationId,
          'lastNotificationDisplayed': null,
        });

        // Update the local event model
        int index = events.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          events[index] = events[index].copyWith(
            notificationId: notificationId,
            lastNotificationDisplayed: null,
          );
        }

        print(
            'Event updated in Firestore and local state for event: ${event.id}');
      } else {
        print(
            'Failed to schedule notification for event: ${event.id}. No exception thrown.');
      }
    } catch (e) {
      print('Error scheduling notification for event ${event.id}: $e');
    }
  }

  Future<void> updateNotification(QuickEventModel event) async {
    // First, cancel the existing notification
    await cancelNotification(event);

    // Then, schedule a new notification
    await scheduleNotification(event);
  }

  Future<void> cancelNotification(QuickEventModel event) async {
    await WorkmanagerNotificationService.cancelNotification(
        event.id, 'calendar');
    try {
      // Cancel the notification using the event's ID as the notification ID
      await AwesomeNotifications().cancel(event.id.hashCode);

      // Try to delete the notification mapping
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .collection('notificationMappings')
            .doc(event.id.hashCode.toString())
            .delete();
      } catch (e) {
        print('Error deleting notification mapping: $e');
        // Continue execution even if this fails
      }

      print('Notification canceled for event: ${event.id}');
    } catch (e) {
      print('Error canceling notification: $e');
      // If it's a permission error, we'll just log it and continue
      if (e.toString().contains('permission-denied')) {
        print(
            'Permission denied when canceling notification. Continuing operation.');
      } else {
        // For other errors, we might want to rethrow or handle differently
        rethrow;
      }
    }
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
        Map<String, dynamic> updateData = {
          'isCompleted': !currentStatus,
        };

        if (!currentStatus) {
          // If marking as complete, add completedAt timestamp and remove reminder
          updateData['completedAt'] = FieldValue.serverTimestamp();
          updateData['hasReminder'] = false;
          updateData['reminderTime'] = FieldValue.delete();
          await _audioPlayer.setAsset('assets/success.mp3');
          await _audioPlayer.play();
        } else {
          // If marking as incomplete, remove completedAt and editedAfterCompletion
          updateData['completedAt'] = FieldValue.delete();
          updateData['editedAfterCompletion'] = FieldValue.delete();
        }

        await eventsCollection.doc(eventId).update(updateData);

        QuickEventModel event = QuickEventModel.fromFirestore(eventDoc);
        if (!currentStatus && event.hasReminder) {
          await cancelNotification(event);
        }

        HapticFeedback.mediumImpact();
        fetchEvents(selectedDay.value);
      }
    } catch (e) {
      print('Error toggling event completion: $e');
    }
  }

  //toggle event reminder
  Future<void> toggleEventReminder(String eventId) async {
    if (currentUser == null) return;
    try {
      DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();
      if (eventDoc.exists) {
        QuickEventModel event = QuickEventModel.fromFirestore(eventDoc);
        bool newReminderStatus = !event.hasReminder;

        Map<String, dynamic> updateData = {
          'hasReminder': newReminderStatus,
          'reminderTime':
              newReminderStatus ? event.reminderTime ?? event.date : null,
          'lastNotificationDisplayed': null, // Reset this field when toggling
        };

        await eventsCollection.doc(eventId).update(updateData);

        if (newReminderStatus) {
          QuickEventModel updatedEvent = QuickEventModel.fromFirestore(
              await eventsCollection.doc(eventId).get());
          await scheduleNotification(updatedEvent);
        } else {
          await cancelNotification(event);
        }

        fetchEvents(selectedDay.value);
        update();
      }
    } catch (e) {
      print('Error toggling event reminder: $e');
    }
  }
}
