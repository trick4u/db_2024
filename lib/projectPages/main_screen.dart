import 'dart:math';
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
    return Scaffold(
      resizeToAvoidBottomInset: false,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: Obx(() => controller.pages[controller.selectedIndex.value]),
      //   bottomNavigationBar: CurvedBottomNavBar(),
      bottomNavigationBar: Obx(() {
        return GlassContainer(
          blur: 10,
          height: 100,
          color: Colors.black,
          shadowColor: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(bottom: 20, top: 20, left: 20, right: 20),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
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
    );
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
                            child: Icon(
                              item.icon,
                              color: controller.currentIndex.value ==
                                      controller.navBarItems.indexOf(item)
                                  ? item.activeColor
                                  : null,
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
                            child: Icon(
                              item.icon,
                              color: controller.currentIndex.value ==
                                      controller.navBarItems.indexOf(item)
                                  ? item.activeColor
                                  : null,
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

class CurvedBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              icon: Icon(Icons.home, color: Colors.white), onPressed: () {}),
          IconButton(
              icon: Icon(Icons.favorite, color: Colors.white),
              onPressed: () {}),
          SizedBox(width: 60), // Space for the center curve
          IconButton(
              icon: Icon(Icons.refresh, color: Colors.white), onPressed: () {}),
          CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 20,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    var path = Path()
      ..moveTo(0, 30)
      ..quadraticBezierTo(size.width / 2, 0, size.width, 30)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CustomPaintedContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(300, 300),
      painter: TexturePainter(),
      child: Center(
        child: Text(
          'Textured Container',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black45,
          ),
        ),
      ),
    );
  }
}

class TexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final texturePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 10) {
      for (double x = 0; x < size.width; x += 10) {
        canvas.drawLine(Offset(x, y), Offset(x + 5, y + 5), texturePaint);
        canvas.drawLine(Offset(x + 5, y), Offset(x, y + 5), texturePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GradientNoiseContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(
        painter: NoisePainter(),
        child: Center(
          child: Text(
            'Textured Container',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}

class NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final random = Random();
    for (double y = 0; y < size.height; y += 1) {
      for (double x = 0; x < size.width; x += 1) {
        if (random.nextDouble() > 0.9) {
          canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
