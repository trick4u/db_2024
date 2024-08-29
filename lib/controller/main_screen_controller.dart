import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tushar_db/constants/colors.dart';
import 'package:tushar_db/projectController/calendar_controller.dart';
import 'package:tushar_db/projectController/profile_controller.dart';
import 'package:tushar_db/projectPages/statistics_screen.dart';

import '../models/quick_event_model.dart';
import '../projectController/page_one_controller.dart';
import '../projectController/page_threeController.dart';
import '../projectController/statistics_controller.dart';
import '../projectPages/awesome_noti.dart';
import '../projectPages/main_screen.dart';

import 'package:popover/popover.dart';

import '../projectPages/page_one.dart';
import '../projectPages/page_three.dart';
import '../projectPages/page_two_calendar.dart';
import '../projectPages/profile_screen.dart';

class MainScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
  //variables
  final RxInt currentIndex = 0.obs;
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
    if (selectedIndex.value == 0) {
    } else if (selectedIndex.value == 1) {
    } else if (selectedIndex.value == 2) {
      Get.find<StatisticsController>().updateStatistics();
    } else if (selectedIndex.value == 3) {}
  }

   void incrementIndex() {
    if (selectedIndex.value < 3) {
      selectedIndex.value++;
    } else {
      selectedIndex.value = 0;
    }
  }

  final List<Widget> pages = [
    PageOneScreen(),
    CalendarPage(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  void onInit() {
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => StatisticsController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut<CalendarController>(() => CalendarController());
    super.onInit();
  }

  Color scaffoldBackgroundColor() {
    switch (selectedIndex.value) {
      case 0:
        return ColorsConstants().lightPurple;
      case 1:
        return ColorsConstants().lightPink;
      case 2:
        return ColorsConstants().lightOrange;
      case 3:
        return Colors.grey[200]!;
      default:
        return Colors.black;
    }
  }

  // if page index ==2 then show dialog
  void showDialog(BuildContext context) {
    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(200, 700, 20, 0),
        popUpAnimationStyle: AnimationStyle(
          curve: Curves.bounceInOut,
          duration: Duration(milliseconds: 500),
          reverseCurve: Curves.linear,
          reverseDuration: Duration(milliseconds: 500),
        ),
        items: [
          PopupMenuItem(
            child: Text('Settings'),
          ),
          PopupMenuItem(
            child: Text('Log Out'),
          ),
        ]);
  }

  //persistent bottom navigation bar

}



//




