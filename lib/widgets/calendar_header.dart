import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../projectController/calendar_controller.dart';

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
              controller.calendarFormat == CalendarFormat.month
                  ? FontAwesomeIcons.calendarWeek
                  : FontAwesomeIcons.calendarAlt,
              size: 20,
            ),
            onPressed: () {
              controller.toggleCalendarFormat();
            },
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (controller.canAddEvent(controller.selectedDay)) {
                if (controller.canAddMoreEvents(controller.selectedDay)) {
                  controller.showEventBottomSheet(context);
                } else {
                  Get.snackbar(
                    'Event Limit Reached',
                    'You can only add up to 10 events per day.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              } else {
                Get.snackbar(
                  'Cannot Add Event',
                  'Events cannot be added to past dates.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
