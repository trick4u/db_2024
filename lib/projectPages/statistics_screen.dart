import 'package:animate_do/animate_do.dart';
import 'package:dough/dough.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tushar_db/constants/colors.dart';

import '../projectController/statistics_controller.dart';
import '../services/app_text_style.dart';
import '../services/app_theme.dart';

class StatisticsScreen extends GetWidget<StatisticsController> {
  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Your Stats".toLowerCase(),
          style: appTheme.titleLarge,
        ),
        backgroundColor: appTheme.colorScheme.surface,
        foregroundColor: appTheme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                _buildTasksOverview(appTheme),
                SizedBox(height: 20),
                _buildWeeklyTaskChart(appTheme),
                SizedBox(height: 20),
                _buildUpcomingTasks(appTheme),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksOverview(AppTheme appTheme) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!controller.showCompletedTasks.value) {
                    controller.toggleTaskView();
                  }
                },
                child: SlideInLeft(
                  child: _buildOverviewCard(
                    'Completed Tasks',
                    controller.completedTasks.value.toString(),
                    isSelected: controller.showCompletedTasks.value,
                    appTheme: appTheme,
                  ),
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
                child: SlideInDown(
                  child: _buildOverviewCard(
                    'Pending Tasks',
                    controller.pendingTasks.value.toString(),
                    isSelected: !controller.showCompletedTasks.value,
                    appTheme: appTheme,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildOverviewCard(String title, String value,
      {bool isSelected = false, required AppTheme appTheme}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: appTheme.colorScheme.primary, width: 2)
            : null,
        color: isSelected
            ? appTheme.colorScheme.surface
            : appTheme.colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: appTheme.titleLarge.copyWith(
              color: isSelected
                  ? appTheme.colorScheme.primary
                  : appTheme.colorScheme.onPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: appTheme.bodyMedium.copyWith(
              color: isSelected
                  ? appTheme.colorScheme.primary
                  : appTheme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTaskChart(AppTheme appTheme) {
    return FadeIn(
      child: PressableDough(
        onReleased: (d) {
          controller.toggleTaskView();
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appTheme.cardColor,
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
                        style: appTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      )),
                  Row(
                    children: [
                      Obx(() => controller.canGoBack == true
                          ? IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                  size: 12, color: appTheme.secondaryTextColor),
                              onPressed: controller.goToPreviousWeek,
                            )
                          : SizedBox.shrink()),
                      Obx(() => Text(controller.getDateRangeText(),
                          style:
                              TextStyle(color: appTheme.secondaryTextColor))),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios,
                            size: 12, color: appTheme.secondaryTextColor),
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
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 8,
                      minY: 0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 2,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: appTheme.secondaryTextColor.withOpacity(0.2),
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
                                    color: appTheme.secondaryTextColor,
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
                                  color: appTheme.secondaryTextColor,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.left,
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: controller.hasDataForWeek.value
                          ? List.generate(7, (index) {
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: controller.showCompletedTasks.value
                                        ? controller.weeklyTaskCompletion[index]
                                            .toDouble()
                                        : controller.weeklyPendingTasks[index]
                                            .toDouble(),
                                    color: controller.showCompletedTasks.value
                                        ? appTheme.colorScheme.primary
                                        : appTheme.colorScheme.error,
                                  )
                                ],
                              );
                            })
                          : List.generate(7, (index) {
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: 0,
                                    color: appTheme.secondaryTextColor
                                        .withOpacity(0.2),
                                  )
                                ],
                              );
                            }),
                      barTouchData: BarTouchData(enabled: false),
                      extraLinesData: ExtraLinesData(
                        extraLinesOnTop: true,
                        horizontalLines: [
                          HorizontalLine(
                            y: 4,
                            color: Colors.transparent,
                            strokeWidth: 1,
                            label: HorizontalLineLabel(
                              show: !controller.hasDataForWeek.value,
                              alignment: Alignment.center,
                              style: TextStyle(
                                color: appTheme.secondaryTextColor,
                                fontSize: 16,
                              ),
                              labelResolver: (line) => 'No data present',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
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

  Widget _buildUpcomingTasks(AppTheme appTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tasks in Next 7 Days',
            style: appTheme.titleLarge.copyWith(fontSize: 18)),
        SizedBox(height: 8),
        Obx(() {
          if (controller.upcomingTasks.isEmpty) {
            return Text('No upcoming tasks in the next 7 days.',
                style: appTheme.bodyMedium);
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.upcomingTasks.length,
            itemBuilder: (context, index) {
              final task = controller.upcomingTasks[index];
              return ListTile(
                title: Text(task.title, style: appTheme.bodyMedium),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy - h:mm a').format(task.createdAt),
                  style: appTheme.bodyMedium.copyWith(
                    color: appTheme.secondaryTextColor,
                  ),
                ),
                leading: Icon(Icons.event, color: appTheme.colorScheme.primary),
              );
            },
          );
        }),
      ],
    );
  }
}
