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

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}

class CalendarController extends GetxController {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  RxList<EventModel> events = <EventModel>[].obs; // Use RxList for reactivity

  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  RxMap<DateTime, List<EventModel>> eventsGrouped =
      <DateTime, List<EventModel>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents(selectedDay); // Initial fetch
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

  //get events for day

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
  // Clear previous events before fetching new ones
  events.clear();
  eventsGrouped.clear();

  // Define the start and end of the month
  DateTime startOfMonth = DateTime(day.year, day.month, 1);
  DateTime endOfMonth = DateTime(day.year, day.month + 1, 0);

  // Fetch events for the entire month
  eventsCollection
      .where('date', isGreaterThanOrEqualTo: startOfMonth)
      .where('date', isLessThanOrEqualTo: endOfMonth)
      .snapshots()
      .listen((querySnapshot) {
    eventsGrouped.clear(); // Clear the grouped events before populating
    for (var doc in querySnapshot.docs) {
      EventModel event = EventModel.fromFirestore(doc);
      DateTime eventDate =
          DateTime(event.date.year, event.date.month, event.date.day);

      if (!eventsGrouped.containsKey(eventDate)) {
        eventsGrouped[eventDate] = [];
      }
      eventsGrouped[eventDate]!.add(event);
    }
    update(); // Notify GetX that the data has changed
  });
}

  bool hasEventsForDay(DateTime day) {
    DateTime dateKey = DateTime(day.year, day.month, day.day);
    return eventsGrouped[dateKey]?.isNotEmpty ?? false;
  }

  void updateEvent(
      String eventId, String newTitle, String newDescription) async {
    try {
      await eventsCollection.doc(eventId).update({
        'title': newTitle,
        'description': newDescription,
      });
    } catch (e) {
      print('Error updating event: $e');
    }
  }

  void deleteEvent(String eventId) async {
    try {
      await eventsCollection.doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  Future<void> showEditEventDialog(
      BuildContext context, EventModel event) async {
    String newTitle = event.title;
    String newDescription = event.description;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newTitle = value;
                },
                controller: TextEditingController(text: event.title),
                decoration: InputDecoration(hintText: 'Enter event title'),
              ),
              SizedBox(height: 12),
              TextField(
                onChanged: (value) {
                  newDescription = value;
                },
                controller: TextEditingController(text: event.description),
                decoration:
                    InputDecoration(hintText: 'Enter event description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                updateEvent(event.id, newTitle, newDescription);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // add event dialog
  Future<void> showAddEventDialog(BuildContext context) async {
    String title = '';
    String description = '';
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  title = value;
                },
                decoration: InputDecoration(hintText: 'Enter event title'),
              ),
              SizedBox(height: 12),
              TextField(
                onChanged: (value) {
                  description = value;
                },
                decoration:
                    InputDecoration(hintText: 'Enter event description'),
              ),
               SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                startTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
              },
              child: Text('Select Start Time'),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                endTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
              },
              child: Text('Select End Time'),
            ),
            ],
          ),
          
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (title.isNotEmpty && description.isNotEmpty) {
                  addEvent(title, description, selectedDay);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void addEvent(String title, String description, DateTime date) async {
    try {
      await eventsCollection.add({
        'title': title,
        'description': description,
        'date': Timestamp.fromDate(date),
      });
       fetchEvents(date); 
    } catch (e) {
      print('Error adding event: $e');
    }
  }
  //
}
