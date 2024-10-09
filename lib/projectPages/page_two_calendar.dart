import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import '../services/toast_util.dart';
import '../widgets/calendar_header.dart';
import '../widgets/event_card.dart';
import '../services/app_theme.dart';

class CalendarPage extends GetWidget<CalendarController> {
  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();

    return GetBuilder<CalendarController>(
      builder: (controller) => Obx(
        () {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          } else if (controller.hasError.value) {
            return Center(
              child: Text(
                'Error loading calendar data. Please try again.',
                style: appTheme.bodyMedium,
              ),
            );
          } else {
            return calendarpageWidget(
              appTheme: appTheme,
              controller: controller,
            );
          }
        },
      ),
    );
  }
}

class calendarpageWidget extends StatelessWidget {
  const calendarpageWidget({
    super.key,
    required this.appTheme,
    required this.controller,
  });

  final AppTheme appTheme;
  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ScaleUtil.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'schedule tasks .',
            style: appTheme.titleLarge.copyWith(
              letterSpacing: 1.5,
            ),
          ),
          CustomCalendarHeader(),
          PressableDough(
            onReleased: (d) {
              if (controller.canAddEvent(controller.selectedDay.value)) {
                controller.showEventBottomSheet(context);
              }
            },
            child: FadeIn(
                child: Card(
              elevation: ScaleUtil.scale(4),
              color: appTheme.cardColor,
              child: LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    //video
                    // Positioned.fill(
                    //   child: Padding(
                    //     padding: EdgeInsets.all(
                    //         ScaleUtil.scale(8)), // Match TableCalendar padding
                    //     child: ClipRRect(
                    //       borderRadius:
                    //           BorderRadius.circular(ScaleUtil.scale(8)),
                    //       child: Obx(() {
                    //         final videoController =
                    //             controller.backgroundVideoController.value;
                    //         double containerHeight;
                    //         switch (controller.calendarFormat) {
                    //           case CalendarFormat.month:
                    //             containerHeight = 320 -
                    //                 ScaleUtil.scale(16); // Subtract padding
                    //             break;
                    //           case CalendarFormat.twoWeeks:
                    //             containerHeight = 180 -
                    //                 ScaleUtil.scale(16); // Subtract padding
                    //             break;
                    //           case CalendarFormat.week:
                    //           default:
                    //             containerHeight = 130 -
                    //                 ScaleUtil.scale(16); // Subtract padding
                    //             break;
                    //         }

                    //         return videoController != null &&
                    //                 videoController.value.isInitialized
                    //             ? FittedBox(
                    //                 fit: BoxFit.cover,
                    //                 child: SizedBox(
                    //                   width: videoController.value.size.width,
                    //                   height: containerHeight,
                    //                   child: VideoPlayer(videoController),
                    //                 ),
                    //               )
                    //             : Container(color: appTheme.cardColor);
                    //       }),
                    //     ),
                    //   ),
                    // ),
                    // // Semi-transparent overlay
                    // Positioned.fill(
                    //   child: Padding(
                    //     padding: EdgeInsets.all(
                    //         ScaleUtil.scale(8)), // Match TableCalendar padding
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         color: Colors.black.withOpacity(0.3),
                    //         borderRadius:
                    //             BorderRadius.circular(ScaleUtil.scale(8)),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(ScaleUtil.scale(8)),
                        child: Obx(() {
                          final imageUrl = controller.backgroundImageUrl.value;
                          return imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                  placeholder: (context, url) =>
                                      Container(color: appTheme.cardColor),
                                  errorWidget: (context, url, error) =>
                                      Container(color: appTheme.cardColor),
                                )
                              : Container(color: appTheme.cardColor);
                        }),
                      ),
                    ),
                    // Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius:
                              BorderRadius.circular(ScaleUtil.scale(8)),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        ScaleUtil.sizedBox(height: 20),
                        FadeIn(
                          child: Padding(
                            padding: ScaleUtil.symmetric(horizontal: 10),
                            child: TableCalendar(
                              firstDay: DateTime.utc(2023, 01, 01),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: controller.focusedDay.value,
                              daysOfWeekHeight: ScaleUtil.height(40),
                              eventLoader: (day) => [],
                              selectedDayPredicate: (day) {
                                return isSameDay(
                                    day, controller.selectedDay.value);
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
                                defaultTextStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScaleUtil.fontSize(14),
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3.0,
                                      color: Colors.black.withOpacity(0.5),
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                                weekendTextStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScaleUtil.fontSize(14),
                                ),
                                holidayTextStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScaleUtil.fontSize(14),
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              headerVisible: false,
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: false,
                                rightChevronIcon: Icon(
                                  Icons.chevron_right,
                                  color: Colors.blue,
                                  size: ScaleUtil.iconSize(24),
                                ),
                                rightChevronPadding:
                                    ScaleUtil.symmetric(horizontal: 100),
                                titleTextStyle: appTheme.titleLarge.copyWith(
                                  fontSize: ScaleUtil.fontSize(18),
                                  color: Colors.blue,
                                ),
                                leftChevronVisible: false,
                                rightChevronVisible: true,
                                headerPadding: ScaleUtil.symmetric(
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
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: ScaleUtil.fontSize(14),
                                ),
                                weekendStyle: TextStyle(
                                  color: Colors.blue.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: ScaleUtil.fontSize(14),
                                ),
                              ),
                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (context, day, focusedDay) {
                                  bool hasEvents =
                                      controller.hasEventsForDay(day);
                                  int eventCount =
                                      controller.getEventCountForDay(day);
                                  return Container(
                                    margin: ScaleUtil.all(4.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          appTheme.colorScheme.primary
                                              .withOpacity(0.1),
                                          Colors.deepPurpleAccent
                                              .withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: ScaleUtil.circular(8.0),
                                      border: hasEvents
                                          ? Border.all(
                                              color: Colors.blue,
                                              width: ScaleUtil.scale(1))
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
                                              fontSize: ScaleUtil.fontSize(12),
                                              color:
                                                  Colors.white, // Always white
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 3.0,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  offset: Offset(1.0, 1.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (eventCount > 0)
                                          Positioned(
                                            right: ScaleUtil.scale(1),
                                            bottom: ScaleUtil.scale(1),
                                            child: Container(
                                              padding: ScaleUtil.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    ScaleUtil.circular(8),
                                              ),
                                              constraints: BoxConstraints(
                                                minWidth: ScaleUtil.width(14),
                                                minHeight: ScaleUtil.height(14),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  eventCount.toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        ScaleUtil.fontSize(7),
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
                                    margin: ScaleUtil.all(4.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          appTheme.colorScheme.primary,
                                          Colors.deepPurpleAccent,
                                        ],
                                      ),
                                      borderRadius: ScaleUtil.circular(8.0),
                                      border: hasEvents
                                          ? Border.all(
                                              color: Colors.white,
                                              width: ScaleUtil.scale(1))
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            date.day.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Euclid',
                                              fontSize: ScaleUtil.fontSize(14),
                                            ),
                                          ),
                                        ),
                                        if (eventCount > 0)
                                          Positioned(
                                            right: ScaleUtil.scale(1),
                                            bottom: ScaleUtil.scale(1),
                                            child: Container(
                                              padding: ScaleUtil.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    ScaleUtil.circular(10),
                                              ),
                                              constraints: BoxConstraints(
                                                minWidth: ScaleUtil.width(15),
                                                minHeight: ScaleUtil.height(15),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  eventCount.toString(),
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontFamily: 'Euclid',
                                                    fontSize:
                                                        ScaleUtil.fontSize(9),
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
                                    margin: ScaleUtil.all(4.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          appTheme.colorScheme.primary
                                              .withOpacity(0.3),
                                          Colors.deepPurpleAccent
                                              .withOpacity(0.3),
                                        ],
                                      ),
                                      borderRadius: ScaleUtil.circular(8.0),
                                      border: hasEvents
                                          ? Border.all(
                                              color: Colors.blue,
                                              width: ScaleUtil.scale(1))
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            date.day.toString(),
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: ScaleUtil.fontSize(14),
                                            ),
                                          ),
                                        ),
                                        if (eventCount > 0)
                                          Positioned(
                                            right: ScaleUtil.scale(1),
                                            bottom: ScaleUtil.scale(1),
                                            child: Container(
                                              padding: ScaleUtil.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    ScaleUtil.circular(10),
                                              ),
                                              constraints: BoxConstraints(
                                                minWidth: ScaleUtil.width(15),
                                                minHeight: ScaleUtil.height(15),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  eventCount.toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        ScaleUtil.fontSize(9),
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
                          ),
                        ),
                        ScaleUtil.sizedBox(height: 10),
                      ],
                    ),
                  ],
                );
              }),
            )),
          ),
          SizedBox(height: ScaleUtil.height(10)),
          Expanded(
            child: Obx(
              () {
                List<QuickEventModel> selectedDayEvents =
                    controller.getEventsForDay(controller.selectedDay.value);
                int eventCount = selectedDayEvents.length;
                int completedEventCount = selectedDayEvents
                    .where((event) => event.isCompleted ?? false)
                    .length;
                return selectedDayEvents.isEmpty
                    ? Center(
                        child: InkWell(
                          onTap: () {
                            if (controller
                                .canAddEvent(controller.selectedDay.value)) {
                              if (controller.canAddMoreEvents(
                                  controller.selectedDay.value)) {
                                controller.showEventBottomSheet(context);
                              } else {
                                ToastUtil.showToast(
                                  'Event Limit Reached',
                                  'You can only add up to 10 events per day.',
                                
                                  backgroundColor: appTheme.colorScheme.surface,
                                
                                );
                              }
                            } else {
                              ToastUtil.showToast(
                                'Cannot Add Event',
                                'Events cannot be added to past dates.',
                              
                                backgroundColor: appTheme.colorScheme.surface,
                              
                              );
                            }
                          },
                          child: Text(
                            'No tasks for ${DateFormat('MMMM dd yyyy').format(controller.selectedDay.value)} ',
                            style: appTheme.bodyMedium,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: ScaleUtil.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total events : $eventCount',
                                  style: appTheme.bodyMedium.copyWith(),
                                ),
                                if (completedEventCount > 0)
                                  Text(
                                    'Completed events : $completedEventCount',
                                    style: appTheme.bodyMedium.copyWith(
                                      color: appTheme.colorScheme.primary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: selectedDayEvents.length,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return EventCard(
                                  onComplete: (event) {
                                    controller.toggleEventCompletion(event.id);
                                  },
                                  onEdit: (event) {
                                    controller.showEventBottomSheet(context,
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
                                          backgroundColor:
                                              appTheme.colorScheme.surface,
                                          title: Text('Confirm Delete',
                                              style: TextStyle(
                                                  color: appTheme.textColor)),
                                          content: Text(
                                              'Are you sure you want to delete this event?',
                                              style: TextStyle(
                                                  color: appTheme.textColor)),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('Cancel',
                                                  style: TextStyle(
                                                      color: appTheme
                                                          .colorScheme
                                                          .primary)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Delete',
                                                  style: TextStyle(
                                                      color: appTheme
                                                          .colorScheme.error)),
                                              onPressed: () {
                                                controller
                                                    .deleteEvent(event.id);
                                                Navigator.of(context).pop();
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
                            ),
                          ),
                        ],
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
