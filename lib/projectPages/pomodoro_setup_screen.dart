import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';


import '../projectController/pomodoro_controller.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';


class PomodoroSetupScreen extends GetWidget<PomodoroController> {
  final AppTheme appTheme = Get.find<AppTheme>();
  final VoidCallback onStart;

  PomodoroSetupScreen({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: ScaleUtil.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ScaleUtil.height(10)),
            _buildSessionDurationSlider(),
            SizedBox(height: ScaleUtil.height(10)),
            _buildBreakDurationSlider(),
            SizedBox(height: ScaleUtil.height(10)),
            _buildTotalSessionsSlider(),
            SizedBox(height: ScaleUtil.height(0)),
            Align(
              alignment: Alignment.centerRight,
              child: _buildStartButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSessionsSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'total sessions',
          style: appTheme.bodyMedium,
        ),
        Obx(() => Slider(
              value: controller.totalSessions.value.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '${controller.totalSessions.value} sessions',
              onChanged: (value) {
                controller.totalSessions.value = value.round();
              },
            )),
      ],
    );
  }

  Widget _buildSessionDurationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'work duration',
          style: appTheme.bodyMedium,
        ),
        Obx(() => Slider(
              value: controller.sessionDuration.value.toDouble(),
              min: 15,
              max: 60,
              divisions: 9,
              label: '${controller.sessionDuration.value} minutes',
              onChanged: (value) {
                controller.sessionDuration.value = value.round();
              },
            )),
      ],
    );
  }

  Widget _buildBreakDurationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'break duration',
          style: appTheme.bodyMedium,
        ),
        Obx(() => Slider(
              value: controller.breakDuration.value.toDouble(),
              min: 3,
              max: 10,
              divisions: 5,
              label: '${controller.breakDuration.value} minutes',
              onChanged: (value) {
                controller.breakDuration.value = value.round();
              },
            )),
      ],
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: onStart,
      child: Container(
        width: ScaleUtil.width(30),
        height: ScaleUtil.height(30),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appTheme.colorScheme.primary,
        ),
        child: Icon(
          FontAwesomeIcons.check,
          color: Colors.white,
          size: ScaleUtil.iconSize(14),
        ),
      ),
    );
  }
}
