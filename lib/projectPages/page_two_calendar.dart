import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../projectController/calendar_controller.dart';
import '../widgets/event_card.dart';

// class CalendarPage extends StatelessWidget {
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController detailsController = TextEditingController();
//   Widget _buildDayContainer(
//       BuildContext context, DateTime date, Color backgroundColor) {
//     return Container(
//       margin: const EdgeInsets.all(4.0),
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(4.0),
//       ),
//       child: Text(
//         date.day.toString(),
//         style: TextStyle(color: Colors.white),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: GetBuilder<CalendarController>(
//         init: CalendarController(),
//         builder: (controller) {
//           return Column(
//             children: [
//               Card(
//                 elevation: 6,
//                 child: Obx(() {
//                   return Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.chevron_left),
//                             onPressed: () {
//                               controller.focusedDay.value = DateTime(
//                                 controller.focusedDay.value.year,
//                                 controller.focusedDay.value.month - 1,
//                               );
//                             },
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               controller.toggleCalendarFormat();
//                             },
//                             child: Text(
//                               DateFormat.yMMMM()
//                                   .format(controller.focusedDay.value),
//                               style: TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.chevron_right),
//                             onPressed: () {
//                               controller.focusedDay.value = DateTime(
//                                 controller.focusedDay.value.year,
//                                 controller.focusedDay.value.month + 1,
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                       TableCalendar(
//                         firstDay: DateTime(2000),
//                         lastDay: DateTime(2100),
//                         focusedDay: controller.focusedDay.value,
//                         calendarFormat: controller.calendarFormat.value,
//                         rangeStartDay: controller.rangeStart.value,
//                         rangeEndDay: controller.rangeEnd.value,
//                         rangeSelectionMode: RangeSelectionMode.toggledOn,
//                         selectedDayPredicate: (day) {
//                           return isSameDay(controller.selectedDay.value, controller.focusedDay.value);
//                         },
//                         onDaySelected: (
//                           selectedDay,
//                           focusedDay,
//                         ) {
//                           controller.onDaySelected(selectedDay, focusedDay);
//                         },
//                         onFormatChanged: (format) {
//                           if (controller.calendarFormat.value != format) {
//                             controller.calendarFormat.value = format;
//                           }
//                         },
//                         onPageChanged: (focusedDay) {
//                           controller.onPageChanged(focusedDay);
//                         },
//                         eventLoader: controller.getEventsForDay,
//                         calendarBuilders: CalendarBuilders(
//                           todayBuilder: (context, date, _) {
//                             return _buildDayContainer(context, date,
//                                 Colors.blue); // You can change this color
//                           },
//                           selectedBuilder: (context, date, _) {
//                             return Container(
//                               margin: const EdgeInsets.all(4.0),
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context).primaryColor,
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               child: Text(
//                                 date.day.toString(),
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             );
//                           },
//                           markerBuilder: (context, date, events) {
//                             if (events.isNotEmpty) {
//                               return Positioned(
//                                 right: 1,
//                                 bottom: 1,
//                                 child: Container(
//                                   padding: EdgeInsets.all(1),
//                                   decoration: BoxDecoration(
//                                     color: Colors.black,
//                                     borderRadius: BorderRadius.circular(5),
//                                   ),
//                                   constraints: BoxConstraints(
//                                     minWidth: 16,
//                                     minHeight: 16,
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       '${events.length}',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }
//                             return SizedBox();
//                           },
//                           defaultBuilder: (context, day, focusedDay) {
//                             if (controller.isDayBlocked(day)) {
//                               return Container(
//                                 margin: const EdgeInsets.all(4.0),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: Colors.redAccent,
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 child: Text(
//                                   day.day.toString(),
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               );
//                             }
//                             return null;
//                           },
//                         ),
//                         calendarStyle: CalendarStyle(
//                           outsideDaysVisible: false,
//                           markersMaxCount: 1,
//                           todayDecoration: BoxDecoration(
//                             color: Colors.blueAccent,
//                             shape: BoxShape.circle,
//                           ),
//                           selectedDecoration: BoxDecoration(
//                             color: Colors.blue,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                         headerVisible: false,
//                         headerStyle: HeaderStyle(
//                           formatButtonVisible: false,
//                           titleCentered: false,
//                         ),
//                       ),
//                     ],
//                   );
//                 }),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) {
//                       final TextEditingController titleController =
//                           TextEditingController();
//                       final TextEditingController detailsController =
//                           TextEditingController();
//                       DateTime startDate = DateTime.now();
//                       DateTime endDate = DateTime.now().add(Duration(hours: 1));
//                       Color eventColor = Colors.blue;

//                       return AlertDialog(
//                         title: Text('Add Event'),
//                         content: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             TextField(
//                               controller: titleController,
//                               decoration: InputDecoration(labelText: 'Title'),
//                             ),
//                             TextField(
//                               controller: detailsController,
//                               decoration: InputDecoration(labelText: 'Details'),
//                             ),
//                             ElevatedButton(
//                               onPressed: () async {
//                                 DateTime? pickedDate = await showDatePicker(
//                                   context: context,
//                                   initialDate: startDate,
//                                   firstDate: DateTime(2000),
//                                   lastDate: DateTime(2101),
//                                 );
//                                 if (pickedDate != null) {
//                                   startDate = pickedDate;
//                                 }
//                               },
//                               child: Text('Select Start Date'),
//                             ),
//                             ElevatedButton(
//                               onPressed: () async {
//                                 DateTime? pickedDate = await showDatePicker(
//                                   context: context,
//                                   initialDate: endDate,
//                                   firstDate: DateTime(2000),
//                                   lastDate: DateTime(2101),
//                                 );
//                                 if (pickedDate != null) {
//                                   endDate = pickedDate;
//                                 }
//                               },
//                               child: Text('Select End Date'),
//                             ),
//                             // Add color picker or other UI for selecting color if necessary
//                           ],
//                         ),
//                         actions: [
//                           ElevatedButton(
//                             onPressed: () {
//                               final newEvent = Event(
//                                 title: titleController.text,
//                                 details: detailsController.text,
//                                 start: startDate,
//                                 end: endDate,
//                                 color: eventColor,
//                                 date: controller.selectedDay.value,
//                               );
//                               controller.addEventToFirestore(newEvent);
//                               Navigator.of(context).pop();
//                             },
//                             child: Text('Add Event'),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 },
//                 child: Text('Add Event'),
//               ),
//               Obx(() {
//                 List<Event> selectedEvents =
//                     controller.events[controller.selectedDay.value] ?? [];

//                 return Expanded(
//                   child: ListView.builder(
//                     itemCount: selectedEvents.length,
//                     itemBuilder: (context, index) {
//                       Event event = selectedEvents[index];
//                       return ListTile(
//                         title: Text(event.title),
//                         subtitle: Text(event.details),
//                         trailing: Icon(Icons.circle, color: event.color),
//                       );
//                     },
//                   ),
//                 );
//               }),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class Event {
//   String id;
//   final String title;
//   final String details;
//   final DateTime start;
//   final DateTime end;
//   final Color color;
//   final DateTime date;

//   Event({
//     this.id = '',
//     required this.title,
//     required this.details,
//     required this.start,
//     required this.end,
//     required this.color,
//     required this.date,
//   });

//   factory Event.fromDocument(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return Event(
//       id: doc.id,
//       title: data['title'],
//       details: data['details'],
//       start: (data['start'] as Timestamp).toDate(),
//       end: (data['end'] as Timestamp).toDate(),
//       color: Color(data['color']),
//       date: (data['date'] as Timestamp).toDate(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'title': title,
//       'details': details,
//       'start': start,
//       'end': end,
//       'color': color.value,
//       'date': date,
//     };
//   }
// }

// class EventService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<List<Event>> getEventsForDay(DateTime day) async {
//     QuerySnapshot querySnapshot = await _firestore
//         .collection('events')
//         .where('date', isEqualTo: Timestamp.fromDate(day))
//         .get();
//     return querySnapshot.docs.map((doc) => Event.fromDocument(doc)).toList();
//   }
// }

class CalendarPage extends StatelessWidget {
  final CalendarController controller = Get.put(CalendarController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Calendar Example'),
        ),
        body: SafeArea(
          child: GetBuilder<CalendarController>(
            builder: (controller) => Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2023, 01, 01),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: controller.focusedDay,
                  eventLoader:
                      controller.getEventsForDay(controller.selectedDay),
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
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 20),
                  ),
                  onHeaderTapped: (focusedDay) {
                    controller.toggleCalendarFormat();
                    controller.setFocusedDay(focusedDay);
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      bool isToday = isSameDay(day, DateTime.now());
                      bool isSelected = isSameDay(day, controller.selectedDay);
                      int eventCount = controller.getEventCountForDay(day);

                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : isToday
                                  ? Colors.blue.withOpacity(0.3)
                                  : null,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                day.day.toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                          ? Colors.blue
                                          : Colors.black,
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
                                    color:
                                        isSelected ? Colors.white : Colors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 15,
                                    minHeight: 15,
                                  ),
                                  child: Center(
                                    child: Text(
                                      eventCount.toString(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Colors.white,
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
                    selectedBuilder: (context, date, _) {
                      int eventCount = controller.getEventCountForDay(date);
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
                                style: TextStyle(color: Colors.white),
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
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 15,
                                    minHeight: 15,
                                  ),
                                  child: Center(
                                    child: Text(
                                      eventCount.toString(),
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
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
                      int eventCount = controller.getEventCountForDay(date);
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
                                    borderRadius: BorderRadius.circular(10),
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
                ElevatedButton(
                  onPressed: () {
                    _showAddEventDialog(context);
                  },
                  child: Text('Add Event'),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Obx(() => ListView.builder(
                        itemCount: controller.events.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(controller.events[index].title),
                            subtitle:
                                Text(controller.events[index].description),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditEventDialog(
                                        context, controller.events[index]);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    controller.deleteEvent(
                                        controller.events[index].id);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    String title = '';
    String description = '';

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
                  controller.addEvent(
                      title, description, controller.selectedDay);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditEventDialog(
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
                controller.updateEvent(event.id, newTitle, newDescription);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
