import 'dart:math';

import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tushar_db/services/app_text_style.dart';

import '../app_routes.dart';
import '../controller/home_controller.dart';
import '../controller/theme_controller.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';
import '../widgets/registration_form.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          //   _buildCircularIcons(),
          Positioned(
            bottom: ScaleUtil.height(20),
            left: 0,
            right: 0,
            child: _buildGetStartedWidget(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.pink[50]!],
        ),
      ),
    );
  }

  Widget _buildCircularIcons() {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        child: Stack(
          children: [
            for (int i = 0; i < 6; i++)
              Positioned(
                left: 150 + 120 * cos(i * pi / 3),
                top: 150 + 120 * sin(i * pi / 3),
                child: _buildIcon(i),
              ),
            Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.pink],
                  ),
                ),
                child: Icon(Icons.star, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(int index) {
    List<IconData> icons = [
      Icons.thumb_up,
      Icons.person,
      Icons.location_on,
      Icons.calendar_today,
      Icons.person_outline,
      Icons.person,
    ];
    List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.yellow,
    ];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors[index],
      ),
      child: Icon(icons[index], color: Colors.white),
    );
  }

  Widget _buildGetStartedWidget(BuildContext context) {
    final appTheme = Get.find<AppTheme>();

    return Obx(() => PressableDough(
          onReleased: (s) {
            appTheme.toggleTheme();
          },
          child: Container(
            height: ScaleUtil.height(300),
            margin: ScaleUtil.all(20),
            padding: ScaleUtil.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: appTheme.cardColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ScaleUtil.height(10)),
                Text('Get Started', style: appTheme.titleLarge),
                SizedBox(height: ScaleUtil.height(10)),
                Text(
                  'Register for events, subscribe to calendars and manage events you\'re going to.',
                  style: appTheme.bodyMedium,
                ),
                SizedBox(height: ScaleUtil.height(20)),
                ElevatedButton(
                  child: Text(
                    'Continue with Phone',
                  ),
                  onPressed: () {},
                  style: appTheme.primaryButtonStyle,
                ),
                SizedBox(height: ScaleUtil.height(16)),
                ElevatedButton(
                  child: Text('Continue with Email'),
                  onPressed: () {
                    Get.toNamed(AppRoutes.LOGIN);
                  },
                  style: appTheme.primaryButtonStyle,
                ),
                SizedBox(height: ScaleUtil.height(16)),
              ],
            ),
          ),
        ));
  }
}
