import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/quick_event_mode.dart';
import '../projectPages/page_two_calendar.dart';
import '../widgets/event_bottomSheet.dart';



class CalendarController extends GetxController {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
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
    fetchEvents(selectedDay);
  }

  void setCalendarFormat(CalendarFormat format) {
    calendarFormat = format;
    update();
  }

  void setFocusedDay(DateTime day) {
    focusedDay = day;
    update();
  }

  int getEventCountForDay(DateTime day) {
    DateTime dateKey = DateTime(day.year, day.month, day.day);
    return eventsGrouped[dateKey]?.length ?? 0;
  }

  getEventsForDay(DateTime day) {
    events.clear();
    events.bindStream(
      eventsCollection
          .where('date',
              isGreaterThanOrEqualTo: DateTime(day.year, day.month, day.day))
          .where('date', isLessThan: DateTime(day.year, day.month, day.day + 1))
          .snapshots()
          .map((query) =>
              query.docs.map((doc) => QuickEventModel.fromFirestore(doc)).toList()),
    );
  }

  void setSelectedDay(DateTime day) {
    selectedDay = day;
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
  DateTime endOfMonth = DateTime(day.year, day.month + 1, 0);

  eventsCollection
      .where('date', isGreaterThanOrEqualTo: startOfMonth)
      .where('date', isLessThanOrEqualTo: endOfMonth)
      .snapshots()
      .listen((querySnapshot) {
    eventsGrouped.clear();
    List<QuickEventModel> allEvents = querySnapshot.docs
        .map((doc) => QuickEventModel.fromFirestore(doc))
        .toList();
    
    // Sort events by date in descending order (newest first)
    allEvents.sort((a, b) => b.date.compareTo(a.date));
    
    for (var event in allEvents) {
      DateTime eventDate = DateTime(event.date.year, event.date.month, event.date.day);
      if (!eventsGrouped.containsKey(eventDate)) {
        eventsGrouped[eventDate] = [];
      }
      eventsGrouped[eventDate]!.add(event);
    }
    
    // Sort events for each day
    eventsGrouped.forEach((date, eventList) {
      eventList.sort((a, b) => b.date.compareTo(a.date));
    });
    
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
        initialDate: selectedDay,
        onSave: (title, description, date, startTime, endTime, color) {
          if (event == null) {
            addEvent(title, description, date, startTime, endTime, color);
          } else {
            updateEvent(event.id, title, description, date, startTime, endTime, color);
          }
        },
      ),
    ),
  );
}

void addEvent(String title, String description, DateTime date, TimeOfDay? startTime, TimeOfDay? endTime, Color color) async {
  if (currentUser == null) return;
  try {
    await eventsCollection.add({
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'startTime': startTime != null ? Timestamp.fromDate(DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute)) : null,
      'endTime': endTime != null ? Timestamp.fromDate(DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute)) : null,
      'color': color.value,
    });
    fetchEvents(date);
  } catch (e) {
    print('Error adding event: $e');
  }
}

  void updateEvent(String eventId, String newTitle, String newDescription, DateTime newDate, TimeOfDay? newStartTime, TimeOfDay? newEndTime, Color newColor) async {
  if (currentUser == null) return;
  try {
    await eventsCollection.doc(eventId).update({
      'title': newTitle,
      'description': newDescription,
      'date': Timestamp.fromDate(newDate),
      'startTime': newStartTime != null ? Timestamp.fromDate(DateTime(newDate.year, newDate.month, newDate.day, newStartTime.hour, newStartTime.minute)) : null,
      'endTime': newEndTime != null ? Timestamp.fromDate(DateTime(newDate.year, newDate.month, newDate.day, newEndTime.hour, newEndTime.minute)) : null,
      'color': newColor.value,
    });
    fetchEvents(newDate);
  } catch (e) {
    print('Error updating event: $e');
  }
}
}