import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

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

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final EventService _eventService = EventService();
  Map<DateTime, List<Event>> _events = {};
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _previousSelectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _loadAllEvents();
  }

  void _loadAllEvents() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    Map<DateTime, List<Event>> allEvents = {};

    for (var doc in snapshot.docs) {
      Event event = Event.fromDocument(doc);
      DateTime eventDate =
          DateTime.utc(event.date.year, event.date.month, event.date.day);

      if (allEvents.containsKey(eventDate)) {
        allEvents[eventDate]!.add(event);
      } else {
        allEvents[eventDate] = [event];
      }
    }

    setState(() {
      _events = allEvents;
    });

    _loadEventsForDay(_selectedDay);
  }

  void _loadEventsForDay(DateTime day) async {
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    List<Event> events = await _eventService.getEventsForDay(normalizedDay);
    setState(() {
      _events[normalizedDay] = events;
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_previousSelectedDay != null &&
          _getEventsForDay(_previousSelectedDay!).isEmpty) {
        _events.remove(_previousSelectedDay);
      }

      _previousSelectedDay = _selectedDay;
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      // select only one day at a time
      _events.remove(_selectedDay);
    });

    _loadEventsForDay(selectedDay);
  }

  double _getCalendarHeight() {
    switch (_calendarFormat) {
      case CalendarFormat.month:
        return 400;
      case CalendarFormat.twoWeeks:
        return 200;
      case CalendarFormat.week:
        return 100;
      default:
        return 400;
    }
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return EventForm(
          selectedDate: _selectedDay,
          onEventAdded: () {
            _loadEventsForDay(_selectedDay);
            _loadAllEvents();
          },
        );
      },
    ).then((_) {
      if (_previousSelectedDay != null &&
          _getEventsForDay(_previousSelectedDay!).isEmpty) {
        setState(() {
          _events.remove(_previousSelectedDay);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue.withOpacity(0.5),
            child: TableCalendar(
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              //     eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                formatButtonVisible: false, // Hide the format button
                titleCentered: false,
                titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily),
              ),
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              headerVisible: true,

              onHeaderTapped: (focusedDay) {
                //change the calendar format
                setState(() {
                  // Toggle between month and week format
                  _calendarFormat = _calendarFormat == CalendarFormat.month
                      ? CalendarFormat.twoWeeks
                      : CalendarFormat.month;
                });
              },
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily),
                weekendStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily),
              ),
              calendarStyle: CalendarStyle(
                todayTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily),
              ),
              daysOfWeekHeight: 40,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, _) {
                  final events = _events[date];
                  if (events != null && events.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            Colors.orange, // Custom color for dates with events
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  } else {
                    return null; // Return null for dates without events
                  }
                },
                todayBuilder: (context, day, focusedDay) {
                  DateTime normalizedDay =
                      DateTime.utc(day.year, day.month, day.day);
                  if (_events.containsKey(normalizedDay)) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                },
                selectedBuilder: (context, day, focusedDay) {
                  DateTime normalizedDay =
                      DateTime.utc(day.year, day.month, day.day);
                  final events = _getEventsForDay(normalizedDay);
                  if (events.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }
                  // if (_events.containsKey(normalizedDay)) {
                  //   return Container(
                  //     margin: const EdgeInsets.all(4.0),
                  //     alignment: Alignment.center,
                  //     decoration: BoxDecoration(
                  //       color: Colors.blueAccent,
                  //       borderRadius: BorderRadius.circular(8.0),
                  //     ),
                  //     child: Text(
                  //       day.day.toString(),
                  //       style: TextStyle(color: Colors.white),
                  //     ),
                  //   );
                  // } else {
                  //   return null;
                  // }
                },
              ),
            ),
          ),
          //SizedBox(height: _getCalendarHeight()),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForDay(_selectedDay).length,
              itemBuilder: (context, index) {
                Event event = _getEventsForDay(_selectedDay)[index];
                return ListTile(
                  title: Text(event.title),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class Event {
  final String id;
  final String title;
  final DateTime date;

  Event({required this.id, required this.title, required this.date});

  factory Event.fromDocument(DocumentSnapshot doc) {
    return Event(
      id: doc.id,
      title: doc['title'],
      date: (doc['date'] as Timestamp).toDate(),
    );
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

class EventForm extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onEventAdded;

  EventForm({required this.selectedDate, required this.onEventAdded});

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addEvent() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text,
        'date': Timestamp.fromDate(widget.selectedDate),
      });
      widget.onEventAdded();
      Navigator.of(context).pop();
    }
  }

  // okay

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Event'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Event Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addEvent,
          child: Text('Add'),
        ),
      ],
    );
  }
}
