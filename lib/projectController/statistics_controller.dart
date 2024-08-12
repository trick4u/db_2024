import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/quick_event_model.dart';
import 'calendar_controller.dart';
import 'dart:math' as math;

class StatisticsController extends GetxController {
  final calendarController = Get.put(CalendarController());

  final RxList<PieChartSectionData> dayChartData = <PieChartSectionData>[].obs;
  final RxList<PieChartSectionData> weekChartData = <PieChartSectionData>[].obs;
  final RxList<BarChartGroupData> monthChartData = <BarChartGroupData>[].obs;
  final RxDouble maxYValue = 10.0.obs;
  final RxList<int> monthlyData = List.generate(12, (_) => 0).obs;

  @override
  void onInit() {
    super.onInit();
    ever(calendarController.events, (_) => updateChartData());
    updateChartData(); // Initial update
  }

  void updateChartData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dayChartData.assignAll(getEventsByDayPartChartData());
      weekChartData.assignAll(getEventsByWeekChartData());
      monthChartData.assignAll(getEventsByMonthChartData());
      maxYValue.value = getMaxYValue();
      updateMonthlyData();
    });
  }

  List<PieChartSectionData> getEventsByDayPartChartData() {
    Map<String, int> eventCountByDayPart = {
      'Morning': 0,
      'Afternoon': 0,
      'Evening': 0,
    };

    DateTime today = DateTime.now();
    List<QuickEventModel> todayEvents = calendarController.events
        .where((event) =>
            event.date.year == today.year &&
            event.date.month == today.month &&
            event.date.day == today.day)
        .toList();

    for (var event in todayEvents) {
      if (event.startTime != null) {
        int hour = event.startTime!.hour;
        if (hour >= 6 && hour < 12) {
          eventCountByDayPart['Morning'] =
              (eventCountByDayPart['Morning'] ?? 0) + 1;
        } else if (hour >= 12 && hour < 18) {
          eventCountByDayPart['Afternoon'] =
              (eventCountByDayPart['Afternoon'] ?? 0) + 1;
        } else {
          eventCountByDayPart['Evening'] =
              (eventCountByDayPart['Evening'] ?? 0) + 1;
        }
      }
    }

    return eventCountByDayPart.entries.map((entry) {
      return PieChartSectionData(
        color: _getRandomColor(),
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        radius: 50,
        titleStyle: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.5,
      );
    }).toList();
  }

  List<PieChartSectionData> getEventsByWeekChartData() {
    Map<String, int> eventCountByDay = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0
    };

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    List<QuickEventModel> weekEvents = calendarController.events
        .where((event) =>
            event.date.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
            event.date.isBefore(endOfWeek.add(Duration(days: 1))))
        .toList();

    for (var event in weekEvents) {
      String dayKey = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ][event.date.weekday - 1];
      eventCountByDay[dayKey] = (eventCountByDay[dayKey] ?? 0) + 1;
    }

    return eventCountByDay.entries.map((entry) {
      return PieChartSectionData(
        color: _getRandomColor(),
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        radius: 50,
        titleStyle: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.5,
      );
    }).toList();
  }

  List<BarChartGroupData> getEventsByMonthChartData() {
    Map<int, int> eventCountByDay = {};

    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

    List<QuickEventModel> monthEvents = calendarController.events
        .where((event) =>
            event.date.isAfter(startOfMonth.subtract(Duration(days: 1))) &&
            event.date.isBefore(endOfMonth.add(Duration(days: 1))))
        .toList();

    for (var event in monthEvents) {
      int dayKey = event.date.day;
      eventCountByDay[dayKey] = (eventCountByDay[dayKey] ?? 0) + 1;
    }

    return List.generate(endOfMonth.day, (index) {
      int day = index + 1;
      int eventCount = eventCountByDay[day] ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: eventCount.toDouble(),
            color: eventCount > 0
                ? _getRandomColor()
                : Colors.grey.withOpacity(0.2),
            width: 16,
          ),
        ],
        showingTooltipIndicators: eventCount > 0 ? [0] : [],
      );
    });
  }

  void updateMonthlyData() {
    List<int> newMonthlyData = List.generate(12, (_) => 0);

    for (var event in calendarController.events) {
      int month = event.date.month - 1; // 0-based index
      newMonthlyData[month]++;
    }

    monthlyData.assignAll(newMonthlyData);
  }

  double getMaxYValue() {
    if (monthChartData.isEmpty) return 10;
    return monthChartData
        .map((group) => group.barRods.first.toY)
        .reduce(math.max);
  }

  Color _getRandomColor() {
    return Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
        .withOpacity(1.0);
  }
}
