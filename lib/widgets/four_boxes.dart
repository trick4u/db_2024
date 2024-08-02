import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tushar_db/app_routes.dart';

import '../projectController/page_one_controller.dart';
import '../services/app_text_style.dart';
import '../services/app_theme.dart';
class FourBoxes extends GetWidget<PageOneController> {
  const FourBoxes({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();

    return Obx(() => ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          color: appTheme.cardColor,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('all notes',
                                  style: appTheme.titleLarge),
                              IconButton(
                                icon: Icon(Icons.add, color: appTheme.textColor),
                                onPressed: () {
                                  Get.toNamed(AppRoutes.NOTES);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      VerticalDivider(color: appTheme.secondaryTextColor, width: 0.5),
                      Expanded(
                        child: Container(
                          color: appTheme.cardColor,
                          child: Center(
                            child: Text('Tasks',
                                style: appTheme.bodyMedium),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: appTheme.secondaryTextColor, height: 0.5),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: appTheme.cardColor,
                          child: Center(
                            child: Text(
                              'Daily journal',
                              style: appTheme.titleLarge,
                            ),
                          ),
                        ),
                      ),
                      VerticalDivider(color: appTheme.secondaryTextColor, width: 0.5),
                      Expanded(
                        child: Container(
                          color: appTheme.cardColor,
                          child: Center(
                            child: Text(
                              'Reminders',
                              style: appTheme.titleLarge,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}