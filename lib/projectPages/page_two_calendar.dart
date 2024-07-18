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

// class CalendarPage extends StatefulWidget {
//   @override
//   _CalendarPageState createState() => _CalendarPageState();
// }

// class _CalendarPageState extends State<CalendarPage> {
//   final EventService _eventService = EventService();
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime _focusedDay = DateTime.now();
//   DateTime _selectedDay = DateTime.now();

//   Map<DateTime, List<dynamic>> _events = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadEventsForDay(_selectedDay);
//     _fetchEvents();
//   }

//   Future<void> _fetchEvents() async {
//     var snapshot = await FirebaseFirestore.instance.collection('events').get();
//     Map<DateTime, List<dynamic>> fetchedEvents = {};
//     for (var doc in snapshot.docs) {
//       DateTime date = (doc['date'] as Timestamp).toDate();

//       if (fetchedEvents[date] == null) fetchedEvents[date] = [];
//       fetchedEvents[date]!.add(doc['title']);
//     }
//     setState(() {
//       _events = fetchedEvents;
//     });
//     print("Events: $_events");
//   }

//   //make a list of events for the selected day
//   void _loadEventsForDay(DateTime day) async {
//     List<Event> events = await _eventService.getEventsForDay(day);
//     setState(() {
//       _events[day] = events;
//     });
//   }

//   List<dynamic> _getEventsForDay(DateTime day) {
//     return _events[day] ?? [];
//   }

//   Widget _buildEventsMarker(DateTime date, List<dynamic> events) {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.blue,
//       ),
//       width: 16.0,
//       height: 16.0,
//       alignment: Alignment.center,
//       child: Text(
//         '${events.length}',
//         style: TextStyle().copyWith(
//           color: Colors.white,
//           fontSize: 12.0,
//         ),
//       ),
//     );
//   }

//   Widget _buildEventDayCell(DateTime day, List events) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.blue[300],
//         shape: BoxShape.rectangle,
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       margin: const EdgeInsets.all(4.0),
//       alignment: Alignment.center,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Text(
//             '${day.day}',
//             style: TextStyle().copyWith(color: Colors.black),
//           ),
//           if (events.isNotEmpty)
//             Positioned(
//               bottom: 4.0,
//               child: _buildEventsMarker(day, events),
//             ),
//         ],
//       ),
//     );
//   }

//     void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     setState(() {
//       _selectedDay = selectedDay;
//     });
//     _loadEventsForDay(selectedDay);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Calendar'),
//       ),
//       body: Column(
//         children: [
// TableCalendar(
//   firstDay: DateTime.utc(2020, 1, 1),
//   lastDay: DateTime.utc(2030, 1, 1),
//   focusedDay: _focusedDay,
//   selectedDayPredicate: (day) {
//     return isSameDay(_selectedDay, day);
//   },
//   onDaySelected: (selectedDay, focusedDay) {
//     if (!isSameDay(_selectedDay, selectedDay)) {
//       setState(() {
//         _selectedDay = selectedDay;
//         _focusedDay = focusedDay;
//       });
//     }
//   },
//   eventLoader: _getEventsForDay,
//   calendarFormat: _calendarFormat,
//   onFormatChanged: (format) {
//     setState(() {
//       _calendarFormat = format;
//     });
//   },
//   onPageChanged: (focusedDay) {
//     _focusedDay = focusedDay;
//   },
//   calendarBuilders: CalendarBuilders(
//     defaultBuilder: (context, day, focusedDay) {
//       if (_events[day] != null && _events[day]!.isNotEmpty) {
//         return _buildEventDayCell(day, _events[day]!);
//       }
//       return Container(
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           '${day.day}',
//         ),
//       );
//     },
//     selectedBuilder: (context, day, focusedDay) {
//       if (_events[day] != null && _events[day]!.isNotEmpty) {
//         return _buildEventDayCell(day, _events[day]!);
//       }
//       return Container(
//         decoration: BoxDecoration(
//           color: Colors.orange,
//           shape: BoxShape.circle,
//         ),
//         width: 40.0, // Fixed width
//         height: 40.0, // Fixed height
//         alignment: Alignment.center,
//         child: Text(
//           '${day.day}',
//           style: TextStyle().copyWith(color: Colors.white),
//         ),
//       );
//     },
//     todayBuilder: (context, day, focusedDay) {
//       if (_events[day] != null && _events[day]!.isNotEmpty) {
//         return _buildEventDayCell(day, _events[day]!);
//       }
//       return Container(
//         decoration: BoxDecoration(
//           color: Colors.green,
//           shape: BoxShape.circle,
//         ),
//         width: 40.0, // Fixed width
//         height: 40.0, // Fixed height
//         alignment: Alignment.center,
//         child: Text(
//           '${day.day}',
//           style: TextStyle().copyWith(color: Colors.white),
//         ),
//       );
//     },
//   ),
// ),
//           Text('Events'),
//           // get events based on the focused day or selected day

//           Expanded(
//             child: ListView.builder(
//               itemCount:  _getEventsForDay(_selectedDay).length,
//               itemBuilder: (context, index) {
//                 Event event = _getEventsForDay(_selectedDay)[index];
//                 return ListTile(
//                   title: Text(event.title),
//                 );
//               },
//             ),
//           ),
//           // Text(_selectedDay?.toLocal().toString().split(' ')[0] ?? ''),
//           // ..._getEventsForDay(_selectedDay ?? _focusedDay)
//           //     .map((event) => ListTile(
//           //           title: Text(event.toString()),
//           //         )),

//           // Expanded(
//           //   child: FutureBuilder(
//           //       future: FirebaseFirestore.instance.collection("events").get(),
//           //       builder: (context, snapsot) {
//           //         if (snapsot.connectionState == ConnectionState.waiting) {
//           //           return CircularProgressIndicator();
//           //         } else {
//           //           return ListView.builder(
//           //             shrinkWrap: true,
//           //             itemCount: snapsot.data!.docs.length,
//           //             itemBuilder: (context, index) {
//           //               // in accordance to the seleted date
//           //               if (snapsot.data!.docs[index]['date']
//           //                       .toDate()
//           //                       .toString()
//           //                       .split(' ')[0] !=
//           //                   _selectedDay?.toLocal().toString().split(' ')[0]) {
//           //                 return Container();
//           //               } else {
//           //                 return ListTile(
//           //                   title: Text(snapsot.data!.docs[index]['title']),
//           //                   subtitle: Text(
//           //                       (snapsot.data!.docs[index]['date'] as Timestamp)
//           //                           .toDate()
//           //                           .toString()),
//           //                 );
//           //               }
//           //             },
//           //           );
//           //         }
//           //       }),
//           // ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _addEventDialog();
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }

// Future<void> _addEventDialog() async {
//   String eventTitle = '';
//   DateTime selectedDate = _selectedDay ?? _focusedDay;

//   await showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text('Add Event'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             onChanged: (value) {
//               eventTitle = value;
//             },
//             decoration: InputDecoration(hintText: 'Event Title'),
//           ),
//           SizedBox(height: 8.0),
//           TextButton(
//             onPressed: () async {
//               DateTime? pickedDate = await showDatePicker(
//                 context: context,
//                 initialDate: selectedDate,
//                 firstDate: DateTime(2000),
//                 lastDate: DateTime(2101),
//               );
//               if (pickedDate != null) {
//                 setState(() {
//                   selectedDate = pickedDate;
//                 });
//               }
//             },
//             child: Text(
//               'Select Date: ${selectedDate.toLocal()}'.split(' ')[0],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () async {
//             if (eventTitle.isNotEmpty) {
//               await FirebaseFirestore.instance.collection('events').add({
//                 'title': eventTitle,
//                 'date': Timestamp.fromDate(_focusedDay),
//               });
//               setState(() {
//                 if (_events[_focusedDay] == null) _events[_focusedDay] = [];
//                 _events[_focusedDay]!.add(eventTitle);
//               });
//               Navigator.of(context).pop();
//             }
//           },
//           child: Text('Add'),
//         ),
//       ],
//     ),
//   );
// }
// }

class CalendarPage extends StatelessWidget {
  Widget _buildDayContainer(
      BuildContext context, DateTime date, Color backgroundColor) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        date.day.toString(),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<CalendarController>(
        init: CalendarController(),
        builder: (controller) {
          return Column(
            children: [
              Card(
                elevation: 6,
                child: Obx(() {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left),
                            onPressed: () {
                              controller.focusedDay.value = DateTime(
                                controller.focusedDay.value.year,
                                controller.focusedDay.value.month - 1,
                              );
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.toggleCalendarFormat();
                            },
                            child: Text(
                              DateFormat.yMMMM()
                                  .format(controller.focusedDay.value),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right),
                            onPressed: () {
                              controller.focusedDay.value = DateTime(
                                controller.focusedDay.value.year,
                                controller.focusedDay.value.month + 1,
                              );
                            },
                          ),
                        ],
                      ),
                      TableCalendar(
                        firstDay: DateTime(2000),
                        lastDay: DateTime(2100),
                        focusedDay: controller.focusedDay.value,
                        calendarFormat: controller.calendarFormat.value,
                        rangeStartDay: controller.rangeStart.value,
                        rangeEndDay: controller.rangeEnd.value,
                        rangeSelectionMode: RangeSelectionMode.toggledOn,
                        selectedDayPredicate: (day) {
                          return isSameDay(controller.selectedDate.value, day);
                        },
                        onDaySelected: (
                          selectedDay,
                          focusedDay,
                        ) {
                          controller.onDaySelected(selectedDay, focusedDay);
                        },
                        onFormatChanged: (format) {
                          if (controller.calendarFormat.value != format) {
                            controller.calendarFormat.value = format;
                          }
                        },
                        // onRangeSelected: (start, end, focusedDay) {
                        //   controller.onRangeSelected(start, end, focusedDay);
                        // },
                        onPageChanged: (focusedDay) {
                          controller.onPageChanged(focusedDay);
                        },
                        eventLoader: controller.getEventsForDay,
                        calendarBuilders: CalendarBuilders(
                          todayBuilder: (context, date, _) {
                            return _buildDayContainer(context, date,
                                Colors.blue); // You can change this color
                          },
                          selectedBuilder: (context, date, _) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          },
                          markerBuilder: (context, date, events) {
                            if (events.isNotEmpty) {
                              return Positioned(
                                right: 1,
                                bottom: 1,
                                child: Container(
                                  padding: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${events.length}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return SizedBox();
                          },
                          defaultBuilder: (context, day, focusedDay) {
                            if (controller.isDayBlocked(day)) {
                              return Container(
                                margin: const EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  day.day.toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          markersMaxCount: 1,
                          todayDecoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          // rangeStartDecoration: BoxDecoration(
                          //   color: Colors.green,
                          //   shape: BoxShape.circle,
                          // ),
                          // rangeEndDecoration: BoxDecoration(
                          //   color: Colors.blueAccent,
                          //   shape: BoxShape.circle,
                          // ),
                        ),
                        headerVisible: false,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: false,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showAddEventDialog(context, controller.selectedDate.value);
                },
                child: Text('Add Event'),
              ),
              ElevatedButton(
                onPressed: () {
                  DateTime startOfWeek = controller.selectedDate.value.subtract(
                      Duration(
                          days: controller.selectedDate.value.weekday - 1));
                  controller.blockWeek(startOfWeek);
                },
                child: Text('Block This Week'),
              ),
              Obx(() {
                final selectedEvents =
                    controller.getEventsForDay(controller.selectedDate.value);
                return Expanded(
                  child: ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      controller.reorderEvents(oldIndex, newIndex);
                    },
                    children: [
                      for (int index = 0;
                          index < selectedEvents.length;
                          index++)
                        EventCard(
                          key: ValueKey(selectedEvents[index].id),
                          event: selectedEvents[index],
                          onDelete: (event) {
                            controller.deleteEvent(event);
                          },
                          onEdit: (event) {
                            controller.showEditEventDialog(context, event);
                          },
                        ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  void showAddEventDialog(BuildContext context, DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (context) {
        return EventForm(
          selectedDate: selectedDay,
          onEventAdded: () {
            final calendarController = Get.find<CalendarController>();
            calendarController.loadAllEvents();
          },
        );
      },
    );
  }
}
// class CalendarPage extends StatefulWidget {
//   @override
//   _CalendarPageState createState() => _CalendarPageState();
// }

// class _CalendarPageState extends State<CalendarPage> {
//   final EventService _eventService = EventService();
//   Map<DateTime, List<Event>> _events = {};
//   DateTime _selectedDay = DateTime.now();
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _previousSelectedDay;
//   CalendarFormat _calendarFormat = CalendarFormat.month;

//   @override
//   void initState() {
//     super.initState();
//     _loadAllEvents();
//     _loadEventsForDay(_selectedDay);
//   }

//   void _loadAllEvents() async {
//     QuerySnapshot snapshot =
//         await FirebaseFirestore.instance.collection('events').get();
//     Map<DateTime, List<Event>> allEvents = {};

//     for (var doc in snapshot.docs) {
//       Event event = Event.fromDocument(doc);
//       DateTime eventDate =
//           DateTime.utc(event.date.year, event.date.month, event.date.day);

//       if (allEvents.containsKey(eventDate)) {
//         allEvents[eventDate]!.add(event);
//       } else {
//         allEvents[eventDate] = [event];
//       }
//     }

//     setState(() {
//       _events = allEvents;
//     });

//     _loadEventsForDay(_selectedDay);
//   }

//   void _loadEventsForDay(DateTime day) async {
//     DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
//     List<Event> events = await _eventService.getEventsForDay(normalizedDay);
//     setState(() {
//       _events[normalizedDay] = events;
//     });
//   }

//   List<Event> _getEventsForDay(DateTime day) {
//     DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
//     return _events[normalizedDay] ?? [];
//   }

//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     setState(() {
//       if (_previousSelectedDay != null &&
//           _getEventsForDay(_previousSelectedDay!).isEmpty) {
//         _events.remove(_previousSelectedDay);
//       }

//       _previousSelectedDay = _selectedDay;
//       _selectedDay = selectedDay;
//       _focusedDay = focusedDay;
//       // select only one day at a time
//       _events.remove(_selectedDay);
//     });

//     _loadEventsForDay(selectedDay);
//   }

//   double _getCalendarHeight() {
//     switch (_calendarFormat) {
//       case CalendarFormat.month:
//         return 400;
//       case CalendarFormat.twoWeeks:
//         return 200;
//       case CalendarFormat.week:
//         return 100;
//       default:
//         return 400;
//     }
//   }

//   void _showAddEventDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return EventForm(
//           selectedDate: _selectedDay,
//           onEventAdded: () {
//             _loadEventsForDay(_selectedDay);
//             _loadAllEvents();
//           },
//         );
//       },
//     ).then((_) {
//       if (_previousSelectedDay != null &&
//           _getEventsForDay(_previousSelectedDay!).isEmpty) {
//         setState(() {
//           _events.remove(_previousSelectedDay);
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Card(
//             elevation: 6,
//             child: TableCalendar(
//               firstDay: DateTime(2000),
//               lastDay: DateTime(2100),
//               focusedDay: _focusedDay,
//               calendarFormat: _calendarFormat,
//               selectedDayPredicate: (day) {
//                 return isSameDay(_selectedDay, day);
//               },
//               onDaySelected: _onDaySelected,
//               //     eventLoader: _getEventsForDay,
//               startingDayOfWeek: StartingDayOfWeek.monday,

//               headerStyle: HeaderStyle(
//                 formatButtonVisible: false, // Hide the format button
//                 titleCentered: false,
//                 titleTextStyle: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: GoogleFonts.poppins().fontFamily),
//               ),
//               onFormatChanged: (format) {
//                 if (_calendarFormat != format) {
//                   setState(() {
//                     _calendarFormat = format;
//                   });
//                 }
//               },
//               headerVisible: true,

//               onHeaderTapped: (focusedDay) {
//                 //change the calendar format
//                 print('Header tapped');
//               },
//               daysOfWeekStyle: DaysOfWeekStyle(
//                 weekdayStyle: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: GoogleFonts.poppins().fontFamily),
//                 weekendStyle: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: GoogleFonts.poppins().fontFamily),
//               ),
//               calendarStyle: CalendarStyle(
//                 todayTextStyle: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: GoogleFonts.poppins().fontFamily),
//               ),
//               daysOfWeekHeight: 40,
//               calendarBuilders: CalendarBuilders(
//                 headerTitleBuilder: (context, day) {
//                   // Format the header title
//                   String month = DateFormat.MMMM().format(day);
//                   // get the month

//                   String year = DateFormat.y().format(day);

//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         // Toggle between month and week format
//                         _calendarFormat =
//                             _calendarFormat == CalendarFormat.month
//                                 ? CalendarFormat.twoWeeks
//                                 : CalendarFormat.month;
//                       });
//                     },
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           year,
//                           style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: GoogleFonts.poppins().fontFamily),
//                         ),
//                         Text(
//                           month,
//                           style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: GoogleFonts.poppins().fontFamily),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//                 defaultBuilder: (context, date, _) {
//                   final events = _events[date];
//                   if (events != null && events.isNotEmpty) {
//                     return Container(
//                       margin: const EdgeInsets.all(4.0),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color:
//                             Colors.orange, // Custom color for dates with events
//                         shape: BoxShape.rectangle,
//                       ),
//                       child: Text(
//                         '${date.day}',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     );
//                   } else {
//                     return null; // Return null for dates without events
//                   }
//                 },
//                 todayBuilder: (context, day, focusedDay) {
//                   DateTime normalizedDay =
//                       DateTime.utc(day.year, day.month, day.day);
//                   if (_events.containsKey(normalizedDay)) {
//                     return Container(
//                       margin: const EdgeInsets.all(4.0),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: Colors.purple,
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       child: Text(
//                         day.day.toString(),
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     );
//                   } else {
//                     return Container(
//                       margin: const EdgeInsets.all(4.0),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       child: Text(
//                         day.day.toString(),
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     );
//                   }
//                 },
//                 selectedBuilder: (context, day, focusedDay) {
//                   DateTime normalizedDay =
//                       DateTime.utc(day.year, day.month, day.day);
//                   final events = _getEventsForDay(normalizedDay);
//                   if (events.isNotEmpty) {
//                     return Container(
//                       margin: const EdgeInsets.all(4.0),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       child: Text(
//                         day.day.toString(),
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     );
//                   } else {
//                     return Container(
//                       margin: const EdgeInsets.all(4.0),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: Colors.orange,
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       child: Text(
//                         day.day.toString(),
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     );
//                   }
//                   // if (_events.containsKey(normalizedDay)) {
//                   //   return Container(
//                   //     margin: const EdgeInsets.all(4.0),
//                   //     alignment: Alignment.center,
//                   //     decoration: BoxDecoration(
//                   //       color: Colors.blueAccent,
//                   //       borderRadius: BorderRadius.circular(8.0),
//                   //     ),
//                   //     child: Text(
//                   //       day.day.toString(),
//                   //       style: TextStyle(color: Colors.white),
//                   //     ),
//                   //   );
//                   // } else {
//                   //   return null;
//                   // }
//                 },
//               ),
//             ),
//           ),
//           //SizedBox(height: _getCalendarHeight()),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               _showAddEventDialog();
//             },
//             child: Text('Add Event'),
//           ),
//           // if events are  available for the selected day display them

//           Expanded(
//             child: ListView.builder(
//               itemCount: _getEventsForDay(_selectedDay).length,
//               itemBuilder: (context, index) {
//                 Event event = _getEventsForDay(_selectedDay)[index];
//                 return ListTile(
//                   title: Text(event.title),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class Event {
  String id;
  String title;
  String details;
  DateTime start;
  DateTime end;
  Color color;

  Event({
    required this.id,
    required this.title,
    required this.details,
    required this.start,
    required this.end,
    required this.color,
  });

  factory Event.fromDocument(DocumentSnapshot doc) {
    return Event(
      id: doc.id,
      title: doc.get('title') ?? '',
      details: (doc.data() as Map<String, dynamic>).containsKey('details')
          ? doc.get('details')
          : '',
      start: (doc.get('start') as Timestamp).toDate(),
      end: (doc.get('end') as Timestamp).toDate(),
      color: Color(doc.get('color') ?? 0xFF000000), // Default color if not set
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'color': color.value,
    };
  }
}

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Event>> getEventsForDay(DateTime day) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('events')
        .where('date', isEqualTo: Timestamp.fromDate(day))
        .get();
    return querySnapshot.docs.map((doc) => Event.fromDocument(doc)).toList();
  }
}

class EventForm extends StatelessWidget {
  final DateTime selectedDate;
  final Function onEventAdded;
  final Event? event;
  final bool isEditing;

  EventForm({
    required this.selectedDate,
    required this.onEventAdded,
    this.event,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventFormController(selectedDate, event: event, isEditing: isEditing));

    return AlertDialog(
      title: Text(isEditing ? 'Edit Event' : 'Add Event'),
      content: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: controller.titleController,
                decoration: InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: controller.detailsController,
                decoration: InputDecoration(labelText: 'Event Details'),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Obx(() => ListTile(
                          title: Text('Start: ${controller.startTime.value.format(context)}'),
                          onTap: () =>
                              controller.pickTime(context, isStartTime: true),
                        )),
                  ),
                  Expanded(
                    child: Obx(() => ListTile(
                          title: Text('End: ${controller.endTime.value.format(context)}'),
                          onTap: () =>
                              controller.pickTime(context, isStartTime: false),
                        )),
                  ),
                ],
              ),
              Obx(() => ListTile(
                    title: Text('Select Color'),
                    trailing: Container(
                      width: 24,
                      height: 24,
                      color: controller.selectedColor.value,
                    ),
                    onTap: () => controller.pickColor(context),
                  )),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(isEditing ? 'Update' : 'Add'),
          onPressed: () {
            if (isEditing) {
              controller.editEvent(context, onEventAdded);
            } else {
              controller.addEvent(context, onEventAdded);
            }
          },
        ),
      ],
    );
  }
}



class EventFormController extends GetxController {
  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController detailsController;
  late Rx<TimeOfDay> startTime;
  late Rx<TimeOfDay> endTime;
  late Rx<Color> selectedColor;
  final DateTime selectedDate;
  final Event? event;
  final bool isEditing;

  EventFormController(this.selectedDate, {this.event, this.isEditing = false}) {
    if (isEditing && event != null) {
      titleController = TextEditingController(text: event!.title);
      detailsController = TextEditingController(text: event!.details);
      startTime = TimeOfDay.fromDateTime(event!.start).obs;
      endTime = TimeOfDay.fromDateTime(event!.end).obs;
      selectedColor = event!.color.obs;
    } else {
      titleController = TextEditingController();
      detailsController = TextEditingController();
      startTime = TimeOfDay.now().obs;
      endTime = TimeOfDay.now().obs;
      selectedColor = Colors.blue.obs;
    }
  }

  void pickTime(BuildContext context, {required bool isStartTime}) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? startTime.value : endTime.value,
    );
    if (picked != null) {
      if (isStartTime) {
        startTime.value = picked;
      } else {
        endTime.value = picked;
      }
    }
  }

  void pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            borderColor: selectedColor.value,
            onColorChanged: (color) {
              selectedColor.value = color;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Select'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void addEvent(BuildContext context, Function onEventAdded) {
    if (_validateForm()) {
      final newEvent = _createEventFromForm();
      FirebaseFirestore.instance.collection('events').add(newEvent.toMap()).then((_) {
        onEventAdded();
        Navigator.of(context).pop();
      });
    }
  }

  void editEvent(BuildContext context, Function onEventEdited) {
    if (_validateForm() && event != null) {
      final updatedEvent = _createEventFromForm(id: event!.id);
      FirebaseFirestore.instance
          .collection('events')
          .doc(updatedEvent.id)
          .update(updatedEvent.toMap())
          .then((_) {
        onEventEdited();
        Navigator.of(context).pop();
      });
    }
  }

  bool _validateForm() {
    if (formKey.currentState!.validate()) {
      final start = _createDateTime(startTime.value);
      final end = _createDateTime(endTime.value);

      if (start.isBefore(end)) {
        return true;
      } else {
        Get.snackbar('Invalid Time', 'End time should be after start time');
      }
    }
    return false;
  }

  Event _createEventFromForm({String id = ''}) {
    final start = _createDateTime(startTime.value);
    final end = _createDateTime(endTime.value);

    return Event(
      id: id,
      title: titleController.text,
      details: detailsController.text,
      start: start,
      end: end,
      color: selectedColor.value,
    );
  }

  DateTime _createDateTime(TimeOfDay time) {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      time.hour,
      time.minute,
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    detailsController.dispose();
    super.onClose();
  }
}