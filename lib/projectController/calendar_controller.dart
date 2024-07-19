import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../projectPages/page_two_calendar.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final Color color;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.color,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      color: Color(data['color'] ?? Colors.blue.value),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'color': color.value,
    };
  }
}


class CalendarController extends GetxController {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  RxList<EventModel> events = <EventModel>[].obs;

  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  RxMap<DateTime, List<EventModel>> eventsGrouped =
      <DateTime, List<EventModel>>{}.obs;

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
              query.docs.map((doc) => EventModel.fromFirestore(doc)).toList()),
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
    List<EventModel> allEvents = querySnapshot.docs
        .map((doc) => EventModel.fromFirestore(doc))
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
    try {
      await eventsCollection.doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  void showEventBottomSheet(BuildContext context, {EventModel? event}) {
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