import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../projectController/statistics_controller.dart';
import 'dart:math' as math;

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final StatisticsController controller = Get.put(StatisticsController());
    return Scaffold(
      appBar: AppBar(title: Text('Event Statistics')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text('Events by Day of Week',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
                height: 200,
                child: PieChart(PieChartData(
                    sections: controller.getEventsByDayChartData()))),
            SizedBox(height: 40),
            Text('Events by Month',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: controller
                        .getEventsByMonthChartData()
                        .map((group) => group.barRods.first.toY)
                        .reduce(math.max),
                    barGroups: controller.getEventsByMonthChartData(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(value.toInt().toString());
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            List<String> months = [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec'
                            ];
                            return Text(months[value.toInt() % 12]);
                          },
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
