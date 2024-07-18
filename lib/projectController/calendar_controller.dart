import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../projectPages/page_two_calendar.dart';

class CalendarController extends GetxController {
  var events = <DateTime, List<Event>>{}.obs;
  var blockedWeeks = <DateTime>{}.obs;
  var selectedDate = DateTime.now().obs;
  var focusedDay = DateTime.now().obs;
  var calendarFormat = CalendarFormat.month.obs;
  EventService _eventService = EventService();
  var rangeStart = Rxn<DateTime>();
  var rangeEnd = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadAllEvents();
  }

   void onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    rangeStart.value = start;
    rangeEnd.value = end;
    this.focusedDay.value = focusedDay;
    update();
  }

  void loadAllEvents() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    Map<DateTime, List<Event>> allEvents = {};

    for (var doc in snapshot.docs) {
      Event event = Event.fromDocument(doc);
      DateTime eventDate =
          DateTime.utc(event.start.year, event.start.month, event.start.day);

      if (allEvents.containsKey(eventDate)) {
        allEvents[eventDate]!.add(event);
      } else {
        allEvents[eventDate] = [event];
      }
    }

    // Sort events for each day
    allEvents.forEach((date, eventList) {
      eventList.sort((a, b) => a.start.compareTo(b.start));
    });

    events.value = allEvents;
    update();
  }

  List<Event> getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    List<Event> dayEvents = events[normalizedDay] ?? [];
    dayEvents.sort(
        (a, b) => a.start.compareTo(b.start)); // Sort events by start time
    return dayEvents;
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isDayBlocked(selectedDay)) {
      selectedDate.value = selectedDay;
      this.focusedDay.value = focusedDay;
      update();
    }
  }

  void toggleCalendarFormat() {
    if (calendarFormat.value == CalendarFormat.month) {
      calendarFormat.value = CalendarFormat.week;
    } else {
      calendarFormat.value = CalendarFormat.month;
    }
  }

  void onPageChanged(DateTime focusedDay) {
    this.focusedDay.value = focusedDay;
  }

  void blockWeek(DateTime startOfWeek) {
    blockedWeeks.add(startOfWeek);
  }

  bool isDayBlocked(DateTime day) {
    DateTime startOfWeek = day.subtract(Duration(days: day.weekday - 1));
    return blockedWeeks.contains(startOfWeek);
  }

  void reorderEvents(int oldIndex, int newIndex) {
    final selectedEvents = getEventsForDay(selectedDate.value).toList();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Event item = selectedEvents.removeAt(oldIndex);
    selectedEvents.insert(newIndex, item);

    // Ensure the events map is updated with the newly ordered list
    events[selectedDate.value] = selectedEvents;
    update();
  }

    void deleteEvent(Event event) async {
    await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
    loadAllEvents();
  }

  void updateEvent(Event updatedEvent) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(updatedEvent.id)
        .update(updatedEvent.toMap());
    loadAllEvents();
  }

   void showEditEventDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return EventForm(
          selectedDate: event.start,
          onEventAdded: () => loadAllEvents(),
          event: event,
          isEditing: true,
        );
      },
    );
  }
}
