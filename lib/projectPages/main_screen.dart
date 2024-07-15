import 'dart:ui';

import 'package:dough/dough.dart';
import 'package:dough_sensors/dough_sensors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/pages/network_screen.dart';

import '../constants/colors.dart';
import '../controller/main_screen_controller.dart';
import 'package:animate_gradient/animate_gradient.dart';

import '../controller/network_controller.dart';

class MainScreen extends GetWidget<MainScreenController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: controller.scaffoldBackgroundColor(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          // floatingActionButton: Padding(
          //   padding: const EdgeInsets.all(10.0),
          //   child: FabButton(),
          // ),
          body: Obx(() => controller.pages[controller.selectedIndex.value]),
          bottomNavigationBar: Obx(() {
            return GlassContainer(
              blur: 10,
              height: 100,
              color: Colors.black,
              shadowColor: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
           
              
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 20, top: 20, left: 20, right: 20),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home, 0),
                      _buildNavItem(Icons.article, 1),
                      _buildNavItem(Icons.search, 2),
                      _buildNavItem(Icons.add_box, 3),
                    ],
                  ),
                ),
              ),
            );
          }),
        ));
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: controller.selectedIndex.value == index
              ? Colors.black
              : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          icon,
          color: controller.selectedIndex.value == index
              ? Colors.white
              : Colors.black,
          size: 30,
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.controller,
  });

  final MainScreenController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomAppBar(
            color: Colors.white,
            //  shadowColor: Colors.grey.withOpacity(0.7),
            shape: const CircularNotchedRectangle(),
            notchMargin: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: controller.navBarItems
                      .sublist(0, 2)
                      .map((item) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: IconButton(
                              onPressed: () => controller.changePage(
                                controller.navBarItems.indexOf(item),
                                context,
                              ),
                              icon: Icon(
                                item.icon,
                                color: controller.currentIndex.value ==
                                        controller.navBarItems.indexOf(item)
                                    ? item.activeColor
                                    : null,
                              ),
                            ),
                          ))
                      .toList(),

                  // Row 2
                ),
                Row(
                  children: controller.navBarItems
                      .sublist(2, 4)
                      .map((item) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: IconButton(
                              onPressed: () => controller.changePage(
                                controller.navBarItems.indexOf(item),
                                context,
                              ),
                              icon: Icon(
                                item.icon,
                                color: controller.currentIndex.value ==
                                        controller.navBarItems.indexOf(item)
                                    ? item.activeColor
                                    : null,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ));
  }
}

class FabButton extends StatelessWidget {
  final MainScreenController controller = Get.find<MainScreenController>();

  @override
  Widget build(BuildContext context) {
    return PressableDough(
      onReleased: (details) {
        Get.toNamed(AppRoutes.ADDTASK);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 60,
          width: 60,
          //box shadow

          child: AnimateGradient(
            animateAlignments: false,
            duration: const Duration(seconds: 10),
            primaryColors: [
              Colors.pink,
              Colors.pinkAccent,
              ColorsConstants().deepPurple,
            ],
            secondaryColors: [
              Colors.blue,
              Colors.blueAccent,
              ColorsConstants().deepPurple,
            ],
            child: Icon(
              FontAwesomeIcons.plus,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
