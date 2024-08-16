import 'package:dough/dough.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tushar_db/constants/colors.dart';

import '../projectController/statistics_controller.dart';

class StatisticsScreen extends GetView<StatisticsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),

                SizedBox(height: 20),
                _buildTasksOverview(),
                SizedBox(height: 20),
                _buildWeeklyTaskChart(),
                SizedBox(height: 20),
                _buildUpcomingTasks(),
                SizedBox(height: 20),
                //  _buildPendingTasksCategories(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksOverview() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!controller.showCompletedTasks.value) {
                    controller.toggleTaskView();
                  }
                },
                child: _buildOverviewCard(
                  'Completed Tasks',
                  controller.completedTasks.value.toString(),
                  isSelected: controller.showCompletedTasks.value,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (controller.showCompletedTasks.value) {
                    controller.toggleTaskView();
                  }
                },
                child: _buildOverviewCard(
                  'Pending Tasks',
                  controller.pendingTasks.value.toString(),
                  isSelected: !controller.showCompletedTasks.value,
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildOverviewCard(String title, String value,
      {bool isSelected = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildWeeklyTaskChart() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                    controller.showCompletedTasks.value
                        ? 'Completion of Daily Tasks'
                        : 'Pending Daily Tasks',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        size: 14, color: Colors.grey),
                    onPressed: controller.goToPreviousWeek,
                  ),
                  Obx(() => Text(controller.getDateRangeText(),
                      style: TextStyle(color: Colors.grey))),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.grey),
                    onPressed: controller.goToNextWeek,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Obx(() {
              if (!controller.hasDataForWeek.value) {
                return Center(
                  child: Text(
                    'No data present for this week',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }
              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(),
                  minY: 0,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = [
                            'Sun',
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat'
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              titles[value.toInt()],
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.left,
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: controller.showCompletedTasks.value
                              ? controller.weeklyTaskCompletion[index]
                                  .toDouble()
                              : controller.weeklyPendingTasks[index].toDouble(),
                          color: controller.showCompletedTasks.value
                              ? Colors.blue
                              : Colors.red,
                        )
                      ],
                    );
                  }),
                  barTouchData: BarTouchData(enabled: false),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    List<int> data = controller.showCompletedTasks.value
        ? controller.weeklyTaskCompletion
        : controller.weeklyPendingTasks;
    double maxValue =
        data.reduce((curr, next) => curr > next ? curr : next).toDouble();
    return maxValue > 8 ? maxValue : 8; // Ensure minimum of 8 for Y-axis
  }

  String _getDateRangeText() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    String startDate = DateFormat('d/M').format(startOfWeek);
    String endDate = DateFormat('d/M').format(endOfWeek);

    return '$startDate-$endDate';
  }

  Widget _buildUpcomingTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tasks in Next 7 Days',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Obx(() {
          if (controller.upcomingTasks.isEmpty) {
            return Text('No upcoming tasks in the next 7 days.');
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.upcomingTasks.length,
            itemBuilder: (context, index) {
              final task = controller.upcomingTasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy - h:mm a').format(task.createdAt),
                ),
                leading: Icon(Icons.event, color: Colors.blue),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildPendingTasksCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pending Tasks in Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Obx(() => PieChart(
              PieChartData(
                sections: controller.pendingTaskCategories.entries
                    .map((entry) => PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: '${entry.key}\n${entry.value}',
                          color: Colors.primaries[
                              entry.key.hashCode % Colors.primaries.length],
                          radius: 100,
                          titleStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ))
                    .toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 0,
              ),
            )),
      ],
    );
  }
}
