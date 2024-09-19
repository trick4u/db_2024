import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/quick_event_model.dart';
import 'calendar_controller.dart';
import 'dart:math' as math;

import 'page_one_controller.dart';

class StatisticsController extends GetxController with WidgetsBindingObserver {
  final pageOneController = Get.put(PageOneController());
  RxBool isInitializing = true.obs;
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;

  RxInt completedTasks = 0.obs;
  RxInt pendingTasks = 0.obs;
  RxList<int> weeklyTaskCompletion = List.generate(7, (_) => 0).obs;
  RxList<int> weeklyPendingTasks = List.generate(7, (_) => 0).obs;
  RxList<QuickEventModel> upcomingTasks = <QuickEventModel>[].obs;
  RxMap<String, int> pendingTaskCategories = <String, int>{}.obs;
  final RxBool isGradientReversed = false.obs;

  Rx<DateTime> currentWeekStart = DateTime.now().obs;
  RxBool hasDataForWeek = true.obs;
  RxBool showCompletedTasks = true.obs;
  final DateTime _threeMonthsAgo = DateTime.now().subtract(
    Duration(days: 90),
  );
  RxBool canGoBack = true.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    initializeController();
  }
    @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

   @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App has come to the foreground
      refreshData();
    }
  }
    Future<void> initializeController() async {
    try {
      isInitializing.value = true;
      setCurrentWeekStart(DateTime.now());

      ever(pageOneController.upcomingEvents, (_) => updateStatistics());
      ever(pageOneController.pendingEvents, (_) => updateStatistics());
      ever(pageOneController.completedEvents, (_) => updateStatistics());

      await updateStatistics();
    } catch (e) {
      print('Error initializing StatisticsController: $e');
      hasError.value = true;
    } finally {
      isInitializing.value = false;
    }
  }
    Future<void> refreshData() async {
    // Only refresh if not already loading
    if (!isLoading.value) {
      print('Refreshing statistics data');
      await updateStatistics();
    }
  }



  void toggleTaskView() {
    showCompletedTasks.toggle();
    isGradientReversed.toggle();
  }

  bool hasDataForCurrentWeek() {
    return weeklyTaskCompletion.any((count) => count > 0) ||
        weeklyPendingTasks.any((count) => count > 0);
  }

  void setCurrentWeekStart(DateTime date) {
    currentWeekStart.value = date.subtract(Duration(days: date.weekday % 7));
    updateCanGoBack();
  }

  void updateCanGoBack() {
    canGoBack.value = currentWeekStart.value.isAfter(_threeMonthsAgo);
  }

  void goToPreviousWeek() {
    if (canGoBack.value) {
      setCurrentWeekStart(currentWeekStart.value.subtract(Duration(days: 7)));
      updateStatistics();
    } else {
      // Optionally, show a message to the user
      Get.snackbar('Limit Reached', 'Cannot view data older than 3 months');
    }
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

Future<void> updateStatistics() async {
    if (isLoading.value) return; // Prevent multiple simultaneous updates

    isLoading.value = true;
    hasError.value = false;

    try {
    //  await pageOneController.refreshData(); // Ensure PageOneController data is up-to-date
      updateTasksOverview();
      updateWeeklyTaskCompletion();
      updateWeeklyPendingTasks();
      updateUpcomingTasks();
      hasDataForWeek.value = hasDataForCurrentWeek();
    } catch (e) {
      print('Error updating statistics: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
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
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
