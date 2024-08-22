import 'package:animate_do/animate_do.dart';
import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../projectController/journal_controller.dart';
import '../services/app_theme.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../widgets/journal_calendar_header.dart';
import 'journalEntryScreen.dart';

class JournalPage extends GetWidget<JournalController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'your journal..',
          style: appTheme.titleLarge.copyWith(
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: appTheme.colorScheme.surface,
        foregroundColor: appTheme.colorScheme.onSurface,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: GetBuilder<JournalController>(
          builder: (controller) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                JournalCalendarHeader(),
                GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity! < 0) {
                      // Swipe up detected
                      controller.toggleCalendarFormat();
                    }
                  },
                  child: PressableDough(
                    onReleased: (d) {
                      //  controller.showAddEntryDialog(context);
                    },
                    child: FadeInDown(
                      child: Card(
                        elevation: 2,
                        color: appTheme.cardColor,
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            FadeInDown(
                              child: Padding(
                                padding: ScaleUtil.symmetric(horizontal: 10),
                                child: _buildCalendar(),
                              ),
                            ),
                            SizedBox(height: ScaleUtil.height(10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ScaleUtil.height(10)),
                Expanded(
                  child: Obx(() => ListView.builder(
                        itemCount: controller.entries.length,
                        itemBuilder: (context, index) {
                          final entry = controller.entries[index];
                          return ListTile(
                            title: Text(entry.title),
                            subtitle: Text(entry.content),
                            onTap: () =>
                                Get.to(() => JournalEntryScreen(entry: entry)),
                          );
                        },
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2023, 01, 01),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: controller.focusedDay.value,
        selectedDayPredicate: (day) =>
            isSameDay(day, controller.selectedDay.value),
        calendarFormat: controller.calendarFormat.value,
        onDaySelected: (
          selectedDay,
          focusedDay,
        ) {
          controller.setSelectedDay(selectedDay);
          controller.setFocusedDay(focusedDay);
        },
        onFormatChanged: (format) => controller.toggleCalendarFormat(),
        onPageChanged: (focusedDay) {
          controller.setFocusedDay(focusedDay);
          controller.fetchEntries(focusedDay);
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          cellMargin: EdgeInsets.all(4),
          cellPadding: EdgeInsets.all(2),
          defaultTextStyle: TextStyle(color: appTheme.textColor),
          weekendTextStyle: TextStyle(color: appTheme.textColor),
          holidayTextStyle: TextStyle(color: appTheme.textColor),
          selectedDecoration: BoxDecoration(
            color: appTheme.colorScheme.primary,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
          ),
          todayDecoration: BoxDecoration(
            color: appTheme.colorScheme.primary.withOpacity(0.3),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
          ),
          markerDecoration: BoxDecoration(
            color: appTheme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        headerVisible: false,
        daysOfWeekHeight: 40,
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: appTheme.colorScheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          weekendStyle: TextStyle(
            color: appTheme.colorScheme.secondary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: appTheme.colorScheme.primary.withOpacity(0.2),
                  width: 2),
            ),
          ),
        ),
        calendarBuilders: CalendarBuilders(
          selectedBuilder: (context, date, _) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  color: appTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appTheme.colorScheme.primary,
                  ),
                  width: 6,
                  height: 6,
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, JournalEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appTheme.colorScheme.surface,
          title: Text('Confirm Delete',
              style: TextStyle(color: appTheme.textColor)),
          content: Text('Are you sure you want to delete this entry?',
              style: TextStyle(color: appTheme.textColor)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: appTheme.colorScheme.primary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete',
                  style: TextStyle(color: appTheme.colorScheme.error)),
              onPressed: () {
                controller.deleteEntry(entry.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
