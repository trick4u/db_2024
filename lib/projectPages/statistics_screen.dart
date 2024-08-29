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
import '../services/scale_util.dart';

class StatisticsScreen extends GetWidget<StatisticsController> {
  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();
    ScaleUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "your stats",
          style: appTheme.titleLarge.copyWith(fontSize: ScaleUtil.fontSize(20)),
        ),
        backgroundColor: appTheme.colorScheme.surface,
        foregroundColor: appTheme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: ScaleUtil.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTasksOverview(appTheme),
                    ScaleUtil.sizedBox(height: 16),
                    _buildWeeklyTaskChart(appTheme),
                    ScaleUtil.sizedBox(height: 16),
                    Padding(
                      padding: ScaleUtil.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tasks in Next 7 Days',
                            style: appTheme.titleLarge.copyWith(
                              fontSize: ScaleUtil.fontSize(16),
                            ),
                          ),
                          Obx(() {
                            if (controller.upcomingTasks.isNotEmpty) {
                              return Text(
                                'Total upcoming tasks: ${controller.upcomingTasks.length}',
                                style: appTheme.bodyMedium.copyWith(
                                  fontSize: ScaleUtil.fontSize(12),
                                  color: appTheme.secondaryTextColor,
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _buildUpcomingTasks(appTheme),
            ),
          ],
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
            ScaleUtil.sizedBox(width: 8),
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
      padding: ScaleUtil.all(10),
      decoration: BoxDecoration(
        borderRadius: ScaleUtil.circular(10),
        border: isSelected
            ? Border.all(
                color: appTheme.colorScheme.primary, width: ScaleUtil.scale(2))
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
              fontSize: ScaleUtil.fontSize(24),
              color: isSelected
                  ? appTheme.colorScheme.primary
                  : appTheme.colorScheme.onPrimary,
            ),
          ),
          ScaleUtil.sizedBox(height: 4),
          Text(
            title.toLowerCase(),
            style: appTheme.bodyMedium.copyWith(
              fontSize: ScaleUtil.fontSize(12),
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
          padding: ScaleUtil.all(12),
          decoration: BoxDecoration(
            color: appTheme.cardColor,
            borderRadius: ScaleUtil.circular(12),
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
                            fontWeight: FontWeight.bold,
                            fontSize: ScaleUtil.fontSize(14)),
                      )),
                  Row(
                    children: [
                      Obx(() => controller.canGoBack == true
                          ? IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                  size: ScaleUtil.iconSize(12),
                                  color: appTheme.secondaryTextColor),
                              onPressed: controller.goToPreviousWeek,
                            )
                          : SizedBox.shrink()),
                      Obx(() => Text(controller.getDateRangeText(),
                          style: TextStyle(
                            color: appTheme.secondaryTextColor,
                            fontSize: ScaleUtil.fontSize(10),
                          ))),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios,
                            size: ScaleUtil.iconSize(12),
                            color: appTheme.secondaryTextColor),
                        onPressed: controller.goToNextWeek,
                      ),
                    ],
                  ),
                ],
              ),
              ScaleUtil.sizedBox(height: 16),
              SizedBox(
                height: ScaleUtil.height(180),
                child: Obx(() {
                  List<int> currentData = controller.showCompletedTasks.value
                      ? controller.weeklyTaskCompletion
                      : controller.weeklyPendingTasks;
                  bool hasData = currentData.any((count) => count > 0);

                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: hasData ? _getMaxY(currentData) : 8,
                      minY: 0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 2,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: appTheme.secondaryTextColor.withOpacity(0.2),
                            strokeWidth: ScaleUtil.scale(1),
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
                                'Thur',
                                'Fri',
                                'Sat'
                              ];
                              return Padding(
                                padding: ScaleUtil.only(top: 8.0),
                                child: Text(
                                  titles[value.toInt()],
                                  style: TextStyle(
                                    color: appTheme.secondaryTextColor,
                                    fontSize: ScaleUtil.fontSize(10),
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
                                  fontSize: ScaleUtil.fontSize(10),
                                ),
                                textAlign: TextAlign.left,
                              );
                            },
                            reservedSize: ScaleUtil.width(25),
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: currentData[index].toDouble(),
                              color: hasData
                                  ? (controller.showCompletedTasks.value
                                      ? appTheme.colorScheme.primary
                                      : appTheme.colorScheme.error)
                                  : appTheme.secondaryTextColor
                                      .withOpacity(0.2),
                              width: ScaleUtil.width(8),
                              borderRadius: BorderRadius.vertical(
                                top: ScaleUtil.radius(4),
                              ),
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
                            strokeWidth: ScaleUtil.scale(1),
                            label: HorizontalLineLabel(
                              show: !hasData,
                              alignment: Alignment.center,
                              style: TextStyle(
                                color: appTheme.secondaryTextColor,
                                fontSize: ScaleUtil.fontSize(14),
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

  double _getMaxY(List<int> data) {
    double maxValue =
        data.reduce((curr, next) => curr > next ? curr : next).toDouble();
    return maxValue > 8 ? maxValue : 8; // Ensure minimum of 8 for Y-axis
  }

  Widget _buildUpcomingTasks(AppTheme appTheme) {
    return Obx(() {
      if (controller.upcomingTasks.isEmpty) {
        return Center(
          child: Text(
            'No upcoming tasks in the next 7 days.',
            style: appTheme.bodyMedium.copyWith(
              fontSize: ScaleUtil.fontSize(14),
            ),
          ),
        );
      }
      return ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: controller.upcomingTasks.length,
        itemBuilder: (context, index) {
          final task = controller.upcomingTasks[index];
          return ListTile(
            contentPadding: ScaleUtil.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              task.title,
              style: appTheme.bodyMedium.copyWith(
                fontSize: ScaleUtil.fontSize(14),
              ),
            ),
            subtitle: Text(
              DateFormat('MMM dd, yyyy').format(task.date ?? DateTime.now()),
              style: appTheme.bodyMedium.copyWith(
                color: appTheme.secondaryTextColor,
                fontSize: ScaleUtil.fontSize(12),
              ),
            ),
            leading: Icon(Icons.event,
                color: appTheme.colorScheme.primary,
                size: ScaleUtil.iconSize(20)),
          );
        },
      );
    });
  }
}
