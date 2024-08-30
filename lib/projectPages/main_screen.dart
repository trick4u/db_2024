import 'package:animate_do/animate_do.dart';
import 'package:dough/dough.dart';
import 'package:dough_sensors/dough_sensors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:tushar_db/services/scale_util.dart';

import '../constants/colors.dart';
import '../controller/main_screen_controller.dart';
import 'package:animate_gradient/animate_gradient.dart';

import '../controller/network_controller.dart';
import '../services/app_theme.dart';

class MainScreen extends GetWidget<MainScreenController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();
    ScaleUtil.init(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Obx(
          () => controller.pages[controller.selectedIndex.value],
        ),
      ),
      bottomNavigationBar: Obx(() {
        return SlideInUp(
          child: Padding(
            padding: ScaleUtil.only(left: 10, right: 10, bottom: 20),
            child: PressableDough(
              onReleased: (de) {
                controller.incrementIndex();
              },
              child: Container(
                width: ScaleUtil.width(50),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.circular(10),
                ),
                height: ScaleUtil.height(50),
                child: Padding(
                  padding: ScaleUtil.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(FontAwesomeIcons.house, 0, appTheme),
                      _buildNavItem(
                          FontAwesomeIcons.calendarCheck, 1, appTheme),
                      _buildNavItem(FontAwesomeIcons.chartSimple, 2, appTheme),
                      _buildNavItem(FontAwesomeIcons.userGear, 3, appTheme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavItem(IconData icon, int index, AppTheme appTheme) {
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: ScaleUtil.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), shape: BoxShape.rectangle),
        child: Icon(
          icon,
          color: controller.selectedIndex.value == index
              ? Colors.white
              : Colors.grey,
          size: controller.selectedIndex.value == index
              ? ScaleUtil.height(20)
              : ScaleUtil.height(15),
        ),
      ),
    );
  }
}
