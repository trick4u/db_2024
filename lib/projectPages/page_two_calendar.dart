import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dough/dough.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../projectController/calendar_controller.dart';
import '../widgets/event_card.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatelessWidget {
  final CalendarController controller = Get.put(CalendarController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Schedule tasks',
            style: TextStyle(
              fontFamily: "Euclid",
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: SafeArea(
          child: GetBuilder<CalendarController>(
            builder: (controller) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  CustomCalendarHeader(controller: controller),
                  PressableDough(
                    onReleased: (d) {
                      controller.showAddEventDialog(context);
                    },
                    child: Card(
                      elevation: 4,
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          TableCalendar(
                            firstDay: DateTime.utc(2023, 01, 01),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: controller.focusedDay,
                            eventLoader: controller
                                .getEventsForDay(controller.selectedDay),
                            selectedDayPredicate: (day) {
                              return isSameDay(day, controller.selectedDay);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              controller.setSelectedDay(selectedDay);
                              controller.setFocusedDay(focusedDay);
                            },
                            calendarFormat: controller.calendarFormat,
                            onFormatChanged: (format) {
                              controller.setCalendarFormat(format);
                            },
                            onPageChanged: (focusedDay) {
                              controller.setFocusedDay(focusedDay);
                            },
                            headerVisible: false,
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: false,
                              rightChevronIcon: Icon(Icons.chevron_right),
                              rightChevronPadding:
                                  EdgeInsets.symmetric(horizontal: 100),
                              titleTextStyle:
                                  TextStyle(fontSize: 20, fontFamily: 'Euclid'),
                              leftChevronVisible: false,
                              rightChevronVisible: true,
                              headerPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              titleTextFormatter: (date, locale) {
                                return DateFormat.yMMMM().format(date);
                              },
                            ),
                            onHeaderTapped: (focusedDay) {
                              controller.toggleCalendarFormat();
                              controller.setFocusedDay(focusedDay);
                            },
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                int eventCount =
                                    controller.getEventCountForDay(day);
                                return Container(
                                  margin: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Euclid',
                                          ),
                                        ),
                                      ),
                                      if (eventCount > 0)
                                        Positioned(
                                          right: 1,
                                          bottom: 1,
                                          child: Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 15,
                                              minHeight: 15,
                                            ),
                                            child: Center(
                                              child: Text(
                                                eventCount.toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontFamily: 'Euclid',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                              selectedBuilder: (context, date, _) {
                                int eventCount =
                                    controller.getEventCountForDay(date);
                                return Container(
                                  margin: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          date.day.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Euclid',
                                          ),
                                        ),
                                      ),
                                      if (eventCount > 0)
                                        Positioned(
                                          right: 1,
                                          bottom: 1,
                                          child: Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 15,
                                              minHeight: 15,
                                            ),
                                            child: Center(
                                              child: Text(
                                                eventCount.toString(),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontFamily: 'Euclid',
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                              todayBuilder: (context, date, _) {
                                int eventCount =
                                    controller.getEventCountForDay(date);
                                return Container(
                                  margin: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          date.day.toString(),
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                      if (eventCount > 0)
                                        Positioned(
                                          right: 1,
                                          bottom: 1,
                                          child: Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 15,
                                              minHeight: 15,
                                            ),
                                            child: Center(
                                              child: Text(
                                                eventCount.toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Obx(
                      () => ListView.builder(
                        itemCount: controller.events.length,
                        itemBuilder: (context, index) {
                          return EventCard(event: controller.events[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;

  EventCard({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(event.id),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   DateFormat('h:mm a').format(event.start),

              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 12,
              //   ),
              // ),
              SizedBox(height: 4),
              // Text(
              //   DateFormat('h:mm a').format(event.end),
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 12,
              //   ),
              // ),
            ],
          ),
          SizedBox(width: 8),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(event.description),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCalendarHeader extends StatelessWidget {
  final CalendarController controller;

  CustomCalendarHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            DateFormat.yMMMM().format(controller.focusedDay),
            style: TextStyle(fontSize: 20, fontFamily: 'Euclid'),
          ),
          SizedBox(width: 4),
          IconButton(
            icon: Icon(
              Icons.arrow_drop_down,
              size: 30,
            ),
            onPressed: () {
              controller.toggleCalendarFormat();
            },
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              controller.showAddEventDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
