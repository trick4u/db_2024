import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'calendar_controller.dart';
import 'dart:math' as math;

class StatisticsController extends GetxController {
  var calendarController = Get.put(CalendarController());

  List<PieChartSectionData> getEventsByDayChartData() {
    Map<String, dynamic> statistics = calendarController.getEventStatistics();
    Map<String, int> eventCountByDay = statistics['eventCountByDay'];

    return eventCountByDay.entries.map((entry) {
      return PieChartSectionData(
        color: _getRandomColor(),
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        radius: 50,
        titleStyle: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<BarChartGroupData> getEventsByMonthChartData() {
    Map<String, dynamic> statistics = calendarController.getEventStatistics();
    Map<String, int> eventCountByMonth = statistics['eventCountByMonth'];

    return eventCountByMonth.entries.toList().asMap().entries.map((entry) {
      int index = entry.key;
      MapEntry<String, int> monthEntry = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: monthEntry.value.toDouble(),
            color: _getRandomColor(),
          ),
        ],
      );
    }).toList();
  }

  Color _getRandomColor() {
    return Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
        .withOpacity(1.0);
  }
}
