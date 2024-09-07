import 'package:animate_do/animate_do.dart';
import 'package:dough/dough.dart';
import 'package:dough_sensors/dough_sensors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:tushar_db/services/scale_util.dart';

import '../constants/colors.dart';
import '../controller/main_screen_controller.dart';
import 'package:animate_gradient/animate_gradient.dart';

import '../controller/network_controller.dart';
import '../services/app_theme.dart';

class MainScreen extends GetWidget<MainScreenController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);

    // Add this to update status bar color when the screen builds

    final appTheme = Get.find<AppTheme>();
    appTheme.updateStatusBarColor();

    return Obx(
      () => Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: controller.pages[controller.selectedIndex.value],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
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
              color: appTheme.isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: appTheme.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            height: ScaleUtil.height(50),
            child: Padding(
              padding: ScaleUtil.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(FontAwesomeIcons.house, 0),
                  _buildNavItem(FontAwesomeIcons.calendarCheck, 1),
                  _buildNavItem(FontAwesomeIcons.chartSimple, 2),
                  _buildNavItem(FontAwesomeIcons.userGear, 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: ScaleUtil.only(bottom: 6, top: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          shape: BoxShape.rectangle,
        ),
        child: Icon(
          icon,
          color: controller.selectedIndex.value == index
              ? (appTheme.isDarkMode ? Colors.white : Colors.black)
              : Colors.grey,
          size: controller.selectedIndex.value == index
              ? ScaleUtil.height(20)
              : ScaleUtil.height(15),
        ),
      ),
    );
  }

  void _updateStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          appTheme.isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }
}
