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

  Widget _buildGetStartedWidget(BuildContext context) {
    final appTheme = Get.find<AppTheme>();

    return Obx(() => PressableDough(
          onReleased: (s) {
            appTheme.toggleTheme();
          },
          child: Container(
            height: ScaleUtil.height(200),
            margin: ScaleUtil.all(20),
            padding: ScaleUtil.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: appTheme.cardColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ScaleUtil.height(10)),
                Text('Get started', style: appTheme.titleLarge),
                Spacer(),
                Text(
                  'Register for events, subscribe to calendars and manage events you\'re going to.',
                  style: appTheme.bodyMedium,
                ),
                SizedBox(height: ScaleUtil.height(10)),

                ElevatedButton(
                  child: Text('Continue with Email'),
                  onPressed: () {
                    Get.toNamed(AppRoutes.LOGIN);
                  },
                  style: appTheme.primaryButtonStyle,
                ),
                SizedBox(height: ScaleUtil.height(10)),
                // Row(
                //   children: [
                //     Expanded(
                //       child: ElevatedButton(
                //         child: Icon(Icons.apple),
                //         onPressed: () {},
                //         style: appTheme.primaryButtonStyle,
                //       ),
                //     ),
                //     SizedBox(width: ScaleUtil.width(10)),
                //     Expanded(
                //       child: ElevatedButton(
                //         child: Text('G'),
                //         onPressed: () {},
                //         style: appTheme.primaryButtonStyle,
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ));
  }
}
