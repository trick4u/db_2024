import 'package:dough/dough.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tushar_db/constants/colors.dart';

import '../projectController/statistics_controller.dart';
import 'statistics_page.dart';

class StatisticsScreen extends GetView<StatisticsController> {
  StatisticsScreen({Key? key}) : super(key: key) {
    // Initialize TabBarDesignController
    Get.put(TabBarDesignController());
  }

  @override
  Widget build(BuildContext context) {
    final tabController = Get.find<TabBarDesignController>();
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Statistics",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
              const SizedBox(height: 16),
              TabBarDesign(),
              const SizedBox(height: 32),
              Expanded(
                child: TabBarView(
                  controller: tabController.tabController,
                  children: [
                    _buildDayView(),
                    _buildWeekView(),
                    _buildMonthView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Events by Time of Day',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Obx(() {
              if (controller.dayChartData.isEmpty) {
                return Center(child: CircularProgressIndicator());
              } else {
                return AnimatedPieChart(sections: controller.dayChartData);
              }
            }),
          ),
          SizedBox(height: 16),
          _buildLegend(controller.dayChartData),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Events by Day of Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Obx(() {
              if (controller.weekChartData.isEmpty) {
                return Center(child: CircularProgressIndicator());
              } else {
                return AnimatedPieChart(sections: controller.weekChartData);
              }
            }),
          ),
          SizedBox(height: 16),
          _buildLegend(controller.weekChartData),
        ],
      ),
    );
  }

  Widget _buildMonthView() {
    final List<String> months = [
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

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Events by Month',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Obx(
              () => LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          controller.monthlyData.asMap().entries.map((entry) {
                        return FlSpot(
                            entry.key.toDouble(), entry.value.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.blue.withOpacity(0.2)),
                    ),
                  ],
                  minY: 0,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 ||
                              value.toInt() >= months.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                      left: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          return LineTooltipItem(
                            '${months[flSpot.x.toInt()]}: ${flSpot.y.toInt()}',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(List<PieChartSectionData> data) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.map((section) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: section.color,
            ),
            SizedBox(width: 4),
            Text(section.title ?? ''),
          ],
        );
      }).toList(),
    );
  }
}

class TabBarDesign extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TabBarDesignController tabController =
        Get.put(TabBarDesignController());

    return Container(
      height: 60.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.blue,
      ),
      child: TabBar(
        controller: tabController.tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        indicatorWeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(
          fontSize: 16.0,
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16.0,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        tabs: [
          Tab(text: 'Today'),
          Tab(text: 'This week'),
          Tab(text: 'This month'),
        ],
      ),
    );
  }
}

class TabBarDesignController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

@override
Widget build(BuildContext context) {
  return Container(
    height: 60.0,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: Colors.blue,
    ),
    child: TabBar(
      dividerColor: Colors.transparent,
      indicator: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        //shadow

        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      indicatorWeight: 0,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      labelStyle: TextStyle(
          fontSize: 16.0,
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(
        fontSize: 16.0,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      tabs: [
        Tab(text: 'Today'),
        Tab(text: 'This week'),
        Tab(text: 'This month'),
      ],
    ),
  );
}

class AnimatedPieChart extends StatefulWidget {
  final List<PieChartSectionData> sections;

  AnimatedPieChart({required this.sections});

  @override
  _AnimatedPieChartState createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          startDegreeOffset: 180,
          borderData: FlBorderData(show: false),
          sectionsSpace: 1,
          centerSpaceRadius: 0,
          sections: showingSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.sections.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;

      return PieChartSectionData(
        color: widget.sections[i].color,
        value: widget.sections[i].value,
        title: widget.sections[i].title,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
        badgeWidget: _Badge(
          widget.sections[i].value
              .toInt()
              .toString(), // Use the value (event count) for the badge
          size: widgetSize,
          borderColor: widget.sections[i].color,
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final double size;
  final Color borderColor;

  const _Badge(
    this.text, {
    Key? key,
    required this.size,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: FittedBox(
          child: Text(
            text,
            style: TextStyle(
              color: borderColor,
              fontSize: size * .3,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
