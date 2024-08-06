import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dough/dough.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../models/quick_event_model.dart';
import '../projectController/calendar_controller.dart';
import '../widgets/calendar_header.dart';
import '../widgets/event_card.dart';
import '../services/app_theme.dart';

class CalendarPage extends GetWidget<CalendarController> {
  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();

    return Obx(() => Scaffold(
          appBar: AppBar(
            title: Text(
              'schedule tasks .',
              style: appTheme.titleLarge.copyWith(
                letterSpacing: 1.5,
              ),
            ),
            backgroundColor: appTheme.colorScheme.surface,
            foregroundColor: appTheme.colorScheme.onSurface,
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
                        if (controller.canAddEvent(controller.selectedDay)) {
                          controller.showEventBottomSheet(context);
                        } else {
                          return;
                        }
                      },
                      child: Card(
                        elevation: 2,
                        color: appTheme.cardColor,
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            TableCalendar(
                              firstDay: DateTime.utc(2023, 01, 01),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: controller.focusedDay,
                              daysOfWeekHeight: 40,
                              eventLoader: (day) => [],
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
                                controller.fetchEvents(focusedDay);
                              },
                              calendarStyle: CalendarStyle(
                                outsideDaysVisible: false,
                                cellMargin: ScaleUtil.all(4),
                                defaultTextStyle:
                                    TextStyle(color: appTheme.textColor),
                                weekendTextStyle:
                                    TextStyle(color: appTheme.textColor),
                                holidayTextStyle:
                                    TextStyle(color: appTheme.textColor),
                              ),
                              headerVisible: false,
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: false,
                                rightChevronIcon: Icon(Icons.chevron_right,
                                    color: appTheme.textColor),
                                rightChevronPadding:
                                    EdgeInsets.symmetric(horizontal: 100),
                                titleTextStyle: appTheme.titleLarge,
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
                              daysOfWeekStyle: DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  color: appTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                                weekendStyle: TextStyle(
                                  color: appTheme.colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (context, day, focusedDay) {
                                  bool hasEvents =
                                      controller.hasEventsForDay(day);
                                  int eventCount =
                                      controller.getEventCountForDay(day);
                                  return Container(
                                    margin: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: hasEvents
                                          ? Border.all(
                                              color:
                                                  appTheme.colorScheme.primary,
                                              width: 1)
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            day.day.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Euclid',
                                              color: hasEvents
                                                  ? appTheme.colorScheme.primary
                                                  : appTheme.textColor,
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
                                                color: appTheme
                                                    .colorScheme.primary,
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
                                                    color: appTheme
                                                        .colorScheme.onPrimary,
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
                                  bool hasEvents =
                                      controller.hasEventsForDay(date);
                                  int eventCount =
                                      controller.getEventCountForDay(date);
                                  return Container(
                                    margin: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      color: appTheme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: hasEvents
                                          ? Border.all(
                                              color: appTheme
                                                  .colorScheme.onPrimary,
                                              width: 1)
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            date.day.toString(),
                                            style: TextStyle(
                                              color: appTheme
                                                  .colorScheme.onPrimary,
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
                                                color: appTheme
                                                    .colorScheme.onPrimary,
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
                                                    color: appTheme
                                                        .colorScheme.primary,
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
                                  bool hasEvents =
                                      controller.hasEventsForDay(date);
                                  int eventCount =
                                      controller.getEventCountForDay(date);
                                  return Container(
                                    margin: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      color: appTheme.colorScheme.primary
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: hasEvents
                                          ? Border.all(
                                              color:
                                                  appTheme.colorScheme.primary,
                                              width: 1)
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            date.day.toString(),
                                            style: TextStyle(
                                                color: appTheme
                                                    .colorScheme.primary),
                                          ),
                                        ),
                                        if (eventCount > 0)
                                          Positioned(
                                            right: 1,
                                            bottom: 1,
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: appTheme
                                                    .colorScheme.primary,
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
                                                    color: appTheme
                                                        .colorScheme.onPrimary,
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
                            SizedBox(height: ScaleUtil.height(10)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: ScaleUtil.height(10)),
                    Expanded(
                      child: GestureDetector(
                        onVerticalDragEnd: (details) {
                          if (details.primaryVelocity! < 0) {
                            // Swipe up detected
                            controller.toggleCalendarFormat();
                          }
                        },
                        child: Obx(
                          () {
                            List<QuickEventModel> selectedDayEvents = controller
                                .getEventsForDay(controller.selectedDay);
                            return selectedDayEvents.isEmpty
                                ? Center(
                                    child: InkWell(
                                      onTap: () {
                                        if (controller.canAddEvent(
                                            controller.selectedDay)) {
                                          if (controller.canAddMoreEvents(
                                              controller.selectedDay)) {
                                            controller
                                                .showEventBottomSheet(context);
                                          } else {
                                            Get.snackbar(
                                              'Event Limit Reached',
                                              'You can only add up to 10 events per day.',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor:
                                                  appTheme.colorScheme.surface,
                                              colorText: appTheme
                                                  .colorScheme.onSurface,
                                            );
                                          }
                                        } else {
                                          Get.snackbar(
                                            'Cannot Add Event',
                                            'Events cannot be added to past dates.',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor:
                                                appTheme.colorScheme.surface,
                                            colorText:
                                                appTheme.colorScheme.onSurface,
                                          );
                                        }
                                      },
                                      child: Text(
                                        'No events for ${DateFormat('MMMM dd yyyy').format(controller.selectedDay)} ',
                                        style: appTheme.bodyMedium,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: selectedDayEvents.length,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return EventCard(
                                      onComplete: (event){
                                        controller.toggleEventCompletion(event.id);
                                      },
                                        onEdit: (event) {
                                          controller.showEventBottomSheet(
                                              context,
                                              event: event);
                                        },
                                        onArchive: (event) {
                                          controller.addToArchive(event.id);
                                        },
                                        onDelete: (event) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: appTheme
                                                    .colorScheme.surface,
                                                title: Text('Confirm Delete',
                                                    style: TextStyle(
                                                        color: appTheme
                                                            .textColor)),
                                                content: Text(
                                                    'Are you sure you want to delete this event?',
                                                    style: TextStyle(
                                                        color: appTheme
                                                            .textColor)),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text('Cancel',
                                                        style: TextStyle(
                                                            color: appTheme
                                                                .colorScheme
                                                                .primary)),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Delete',
                                                        style: TextStyle(
                                                            color: appTheme
                                                                .colorScheme
                                                                .error)),
                                                    onPressed: () {
                                                      controller.deleteEvent(
                                                          event.id);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        event: selectedDayEvents[index],
                                      );
                                    },
                                  );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
