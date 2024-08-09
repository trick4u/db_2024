import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'calendar_controller.dart';
import 'dart:math' as math;

class StatisticsController extends GetxController {
  final calendarController = Get.put(CalendarController());
  
  final RxList<PieChartSectionData> pieChartData = <PieChartSectionData>[].obs;
  final RxList<BarChartGroupData> barChartData = <BarChartGroupData>[].obs;
  final RxDouble maxYValue = 10.0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(calendarController.events, (_) => updateChartData());
    updateChartData(); // Initial update
  }

  void updateChartData() {
    pieChartData.value = getEventsByDayChartData();
    barChartData.value = getEventsByMonthChartData();
    maxYValue.value = getMaxYValue();
  }

List<PieChartSectionData> getEventsByDayChartData() {
  Map<String, dynamic> statistics = calendarController.getEventStatistics();
  Map<String, int> eventCountByDay = statistics['eventCountByDay'];

  return eventCountByDay.entries.map((entry) {
    return PieChartSectionData(
      color: _getRandomColor(),
      value: entry.value.toDouble(),  // This should be the event count
      title: entry.key.substring(0, 3), // First 3 letters of the day
      radius: 50,
      titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }).toList();
}

  List<BarChartGroupData> getEventsByMonthChartData() {
    Map<String, dynamic> statistics = calendarController.getEventStatistics();
    Map<String, int> eventCountByMonth = statistics['eventCountByMonth'];

    List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    return List.generate(12, (index) {
      String month = months[index];
      int eventCount = eventCountByMonth[month] ?? 0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: eventCount.toDouble(),
            color: eventCount > 0 ? _getRandomColor() : Colors.grey.withOpacity(0.2),
            width: 22,
          ),
        ],
        showingTooltipIndicators: eventCount > 0 ? [0] : [],
      );
    });
  }

  double getMaxYValue() {
    if (barChartData.isEmpty) return 10;
    return barChartData.map((group) => group.barRods.first.toY).reduce(math.max);
  }

  Color _getRandomColor() {
    return Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }
}