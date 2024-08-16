import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/quick_event_model.dart';
import 'calendar_controller.dart';
import 'dart:math' as math;

import 'page_one_controller.dart';

class StatisticsController extends GetxController {
  final pageOneController = Get.put(PageOneController());

 RxInt completedTasks = 0.obs;
  RxInt pendingTasks = 0.obs;
  RxList<int> weeklyTaskCompletion = List.generate(7, (_) => 0).obs;
  RxList<int> weeklyPendingTasks = List.generate(7, (_) => 0).obs;
  RxList<QuickEventModel> upcomingTasks = <QuickEventModel>[].obs;
  RxMap<String, int> pendingTaskCategories = <String, int>{}.obs;

  Rx<DateTime> currentWeekStart = DateTime.now().obs;
  RxBool hasDataForWeek = true.obs;
  RxBool showCompletedTasks = true.obs;

  @override
  void onInit() {
    super.onInit();
    setCurrentWeekStart(DateTime.now());
    updateStatistics();
  }

  void setCurrentWeekStart(DateTime date) {
    // Adjust to start week on Sunday
    currentWeekStart.value = date.subtract(Duration(days: date.weekday % 7));
  }

  void goToPreviousWeek() {
    setCurrentWeekStart(currentWeekStart.value.subtract(Duration(days: 7)));
    updateStatistics();
  }

  void goToNextWeek() {
    DateTime nextWeekStart = currentWeekStart.value.add(Duration(days: 7));
    if (nextWeekStart.isBefore(DateTime.now()) ||
        nextWeekStart.isAtSameMomentAs(DateTime.now())) {
      setCurrentWeekStart(nextWeekStart);
      updateStatistics();
    }
  }

  String getDateRangeText() {
    DateTime endOfWeek = currentWeekStart.value.add(Duration(days: 6));
    String startDate = DateFormat('d/M').format(currentWeekStart.value);
    String endDate = DateFormat('d/M').format(endOfWeek);
    return '$startDate-$endDate';
  }

   void updateStatistics() {
    updateTasksOverview();
    updateWeeklyTaskCompletion();
    updateWeeklyPendingTasks();
    updateUpcomingTasks();
   
  }
 void updateTasksOverview() {
    completedTasks.value = pageOneController.completedEvents.length;
    pendingTasks.value = pageOneController.pendingEvents.length;
  }
  void updateWeeklyTaskCompletion() {
    List<int> newCompletion = List.generate(7, (_) => 0);
    bool hasData = false;

    for (int i = 0; i < 7; i++) {
      DateTime day = currentWeekStart.value.add(Duration(days: i));
      int completedCount = pageOneController.completedEvents
          .where((event) => isSameDay(event.date, day))
          .length;
      newCompletion[i] = completedCount;
      if (completedCount > 0) hasData = true;
    }

    weeklyTaskCompletion.value = newCompletion;
    hasDataForWeek.value = hasData;
  }

  void updateWeeklyPendingTasks() {
    List<int> newPending = List.generate(7, (_) => 0);
    bool hasData = false;

    for (int i = 0; i < 7; i++) {
      DateTime day = currentWeekStart.value.add(Duration(days: i));
      int pendingCount = pageOneController.pendingEvents
          .where((event) => isSameDay(event.date, day))
          .length;
      newPending[i] = pendingCount;
      if (pendingCount > 0) hasData = true;
    }

    weeklyPendingTasks.value = newPending;
    hasDataForWeek.value = hasDataForWeek.value || hasData;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  void toggleTaskView() {
    showCompletedTasks.toggle();
  }


 


  void updateUpcomingTasks() {
    DateTime now = DateTime.now();
    DateTime sevenDaysLater = now.add(Duration(days: 7));

    upcomingTasks.value = pageOneController.upcomingEvents
        .where((event) =>
            event.date.isAfter(now) && event.date.isBefore(sevenDaysLater))
        .toList();
  }
}
