import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tushar_db/app_routes.dart';

import '../projectController/journal_controller.dart';
import '../projectPages/journalEntryScreen.dart';
import '../services/app_theme.dart';

class JournalCalendarHeader extends GetView<JournalController> {
  final appTheme = Get.find<AppTheme>();

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
                headerText = 'Today, ${DateFormat.yMMMM().format(focusedDate)}';
              } else if (isSameDay(focusedDate, tomorrow)) {
                headerText =
                    'Tomorrow, ${DateFormat.yMMMM().format(focusedDate)}';
              } else if (isSameDay(focusedDate, yesterday)) {
                headerText =
                    'Yesterday, ${DateFormat.yMMMM().format(focusedDate)}';
              } else {
                headerText = DateFormat('MMMM d, yyyy').format(focusedDate);
              }

              return Text(
                headerText,
                style: TextStyle(fontSize: 20, fontFamily: 'Euclid'),
                overflow: TextOverflow.ellipsis,
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
              color: appTheme.colorScheme.primary,
            ),
            onPressed: () {
             // controller.toggleCalendarFormat();
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: appTheme.colorScheme.primary),
            onPressed: () {
              Get.to(
                () => JournalEntryScreen(entry: null),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Journal Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(hintText: 'Content'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                controller.addEntry(
                    titleController.text, contentController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
