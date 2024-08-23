import 'package:animate_do/animate_do.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dough/dough.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';
import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/constants/colors.dart';
import 'package:tushar_db/services/app_text_style.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../controller/theme_controller.dart';
import '../models/goals_model.dart';
import '../models/quick_event_model.dart';
import '../projectController/page_one_controller.dart';
import '../projectController/pomodoro_controller.dart';
import '../projectController/statistics_controller.dart';
import '../services/app_theme.dart';
import '../temp/music_view.dart';
import '../widgets/AllSixWidgets.dart';
import '../widgets/event_bottomSheet.dart';
import '../widgets/event_card.dart';
import '../widgets/event_sheet.dart';
import '../widgets/four_boxes.dart';
import '../widgets/goals_box.dart';
import '../widgets/quick_bottomsheet.dart';
import '../widgets/quick_reminder_chips.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';

import '../widgets/reminder_list.dart';
import '../widgets/three_day.dart';
import '../widgets/three_shaped_box.dart';
import 'main_screen.dart';
import 'music_page.dart';

class PageOneScreen extends GetWidget<PageOneController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //text page 1

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Obx(
                  () => Text(
                    controller.greeting.toLowerCase() + ".",
                    style: AppTextTheme.textTheme.displayMedium,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.NOTIFICAION);
                  },
                  child: Icon(FontAwesomeIcons.bell),
                ),
              ],
            ),
            SizedBox(height: ScaleUtil.height(20)),
            FadeIn(
              child: AllSixCards(
                height: ScaleUtil.height(300),
                useFixedHeight: true,
                onListTypeSelected: (listType) {
                  controller.setSelectedListType(listType);
                },
              ),
            ),

            SizedBox(height: ScaleUtil.height(20)),
            Expanded(
              child: Obx(() => controller.selectedListType.value.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _getListTitle(controller.selectedListType.value),
                            style: AppTextTheme.textTheme.titleLarge,
                          ),
                        ),
                        SizedBox(height: ScaleUtil.height(10)),
                        Expanded(
                          child: _buildSelectedList(),
                        ),
                      ],
                    )
                  : SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }

  String _getListTitle(String listType) {
    switch (listType) {
      case 'upcoming':
        return 'Upcoming Tasks'.toLowerCase();
      case 'pending':
        return 'Pending Tasks'.toLowerCase();
      case 'completed tasks':
        return 'Completed Tasks'.toLowerCase();
      case 'all reminders':
        return 'all reminders'.toLowerCase();
      default:
        return '';
    }
  }

  Widget _buildSelectedList() {
    switch (controller.selectedListType.value) {
      case 'all reminders':
        return RemindersList();
      default:
        return FadeInRight(
          child: EventsList(
            events: controller.getSelectedEvents(),
            eventType: controller.selectedListType.value,
          ),
        );
    }
  }


}

