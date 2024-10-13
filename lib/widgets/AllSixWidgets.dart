import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/widgets/pomodoro.dart';

import '../projectController/page_one_controller.dart';
import '../services/app_text_style.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';
import 'quick_bottomsheet.dart';


class AllSixCards extends GetWidget<PageOneController> {
  final double? height;
  final bool useFixedHeight;
  final Function(String) onListTypeSelected;

  AllSixCards({
    this.height,
    this.useFixedHeight = false,
    required this.onListTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    final appTheme = Get.find<AppTheme>();

    Widget gridView = GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: ScaleUtil.width(8.0),
        mainAxisSpacing: ScaleUtil.height(8.0),
        childAspectRatio: 3.0,
      ),
      itemCount: controller.items.length,
      itemBuilder: (context, index) {
        return Obx(() {
          bool isSelected = controller.selectedTile.value ==
              controller.items[index]['title']!.toLowerCase();
          return InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              String tileTitle =
                  controller.items[index]['title']!.toLowerCase();
              if (controller.selectedTile.value == tileTitle) {
                controller.setSelectedTile('');
                controller.toggleGradientDirection();
              } else {
                controller.setSelectedTile(tileTitle);
                controller.toggleGradientDirection();
              }

              if (tileTitle == 'pending' ||
                  tileTitle == 'upcoming' ||
                  tileTitle == 'completed tasks' ||
                  tileTitle == 'all reminders'||  tileTitle == 'pomodoro') {
                onListTypeSelected(tileTitle);
              } else if (tileTitle == 'add reminders') {
                controller.showQuickReminderBottomSheet(context);
              } else if (tileTitle == 'daily journal') {
                Get.toNamed(AppRoutes.JOURNAL);
              } else if (tileTitle == 'take notes') {
                Get.toNamed(AppRoutes.NOTETAKING);
              } else if (tileTitle == 'vision') {
                Get.toNamed(AppRoutes.VISIONBOARD);
              }
            },
            child: AnimatedContainer(
              duration: Duration(microseconds: 100),
              curve: Curves.easeIn,
              decoration: BoxDecoration(
                borderRadius: ScaleUtil.circular(10),
                border: isSelected
                    ? Border.all(
                        color: Colors.deepPurpleAccent,
                        width: ScaleUtil.scale(2))
                    : null,
                gradient: isSelected
                    ? null
                    : LinearGradient(
                        begin: controller.isGradientReversed.value
                            ? Alignment.bottomRight
                            : Alignment.topLeft,
                        end: controller.isGradientReversed.value
                            ? Alignment.topLeft
                            : Alignment.bottomRight,
                        colors: [
                          appTheme.colorScheme.primary,
                          Colors.deepPurpleAccent,
                        ],
                      ),
                color: isSelected ? Colors.white : null,
              ),
              alignment: Alignment.center,
              child: AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 300),
                style: AppTextTheme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: ScaleUtil.fontSize(14),
                  color: isSelected ? Colors.deepPurpleAccent : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.items[index]['title']!.toLowerCase(),
                      textAlign: TextAlign.center,
                    ),
                    if (controller.items[index]['icon'] != null) ...[
                      ScaleUtil.sizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: FaIcon(
                          controller.items[index]['icon'],
                          key: ValueKey<Color>(isSelected
                              ? Colors.deepPurpleAccent
                              : Colors.white),
                          size: ScaleUtil.iconSize(12),
                          color: isSelected
                              ? Colors.deepPurpleAccent
                              : Colors.white,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          );
        });
      },
    );

    if (useFixedHeight) {
      return SizedBox(
        height: height ?? ScaleUtil.height(200),
        child: gridView,
      );
    } else {
      return gridView;
    }
  }
}
