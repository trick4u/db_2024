import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../projectController/calendar_controller.dart';

class CustomCalendarHeader extends GetView<CalendarController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final focusedDate = controller.focusedDay.value;
              final today = DateTime.now();
              final tomorrow = DateTime(today.year, today.month, today.day + 1);
              final yesterday =
                  DateTime(today.year, today.month, today.day - 1);

              String headerText;

              if (isSameDay(focusedDate, today)) {
                headerText = 'today, ${DateFormat.yMMMM().format(focusedDate)}';
              } else if (isSameDay(focusedDate, tomorrow)) {
                headerText =
                    'tomorrow, ${DateFormat.yMMMM().format(focusedDate)}';
              } else if (isSameDay(focusedDate, yesterday)) {
                headerText =
                    'yesterday, ${DateFormat.yMMMM().format(focusedDate)}';
              } else {
                headerText = DateFormat('MMMM d, yyyy').format(focusedDate);
              }

              return GestureDetector(
                onTap: () {
                  controller.fetchRandomBackgroundImage();
                },
                child: Text(
                  headerText,
                  style: TextStyle(fontSize: 20, fontFamily: 'Euclid'),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
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
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (controller.canAddEvent(controller.selectedDay.value)) {
                if (controller.canAddMoreEvents(controller.selectedDay.value)) {
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
