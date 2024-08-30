import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';

import '../projectController/page_one_controller.dart';
import '../services/app_text_style.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';
import 'quick_bottomsheet.dart';
import 'quick_reminder_chips.dart';

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
        return Obx(() => InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                String tileTitle =
                    controller.items[index]['title']!.toLowerCase();
                controller.setSelectedTile(tileTitle);
                if (tileTitle == 'pending' ||
                    tileTitle == 'upcoming' ||
                    tileTitle == 'completed tasks' ||
                    tileTitle == 'all reminders') {
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: ScaleUtil.circular(10),
                  border: controller.selectedTile.value ==
                          controller.items[index]['title']!.toLowerCase()
                      ? Border.all(
                          color: Colors.deepPurpleAccent,
                          width: ScaleUtil.scale(2))
                      : null,
                  color: controller.selectedTile.value ==
                          controller.items[index]['title']!.toLowerCase()
                      ? Colors.white
                      : Colors.deepPurpleAccent,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.items[index]['title']!.toLowerCase(),
                      style: AppTextTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: ScaleUtil.fontSize(14),
                        color: controller.selectedTile.value ==
                                controller.items[index]['title']!.toLowerCase()
                            ? Colors.deepPurpleAccent
                            : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (controller.items[index]['icon'] != null) ...[
                      ScaleUtil.sizedBox(width: 8),
                      FaIcon(
                        controller.items[index]['icon'],
                        size: ScaleUtil.iconSize(12),
                        color: controller.selectedTile.value ==
                                controller.items[index]['title']!.toLowerCase()
                            ? Colors.deepPurpleAccent
                            : Colors.white,
                      ),
                    ]
                  ],
                ),
              ),
            ));
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
