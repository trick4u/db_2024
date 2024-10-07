import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/services/app_text_style.dart';

import '../projectController/pomodoro_controller.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';
import '../widgets/pomodoro.dart';

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
            Align(
              alignment: Alignment.centerRight,
              child: _buildStartButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDurationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Work Session Duration',
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
          'Break Duration',
          style: appTheme.bodyMedium,
        ),
        Obx(() => Slider(
              value: controller.breakDuration.value.toDouble(),
              min: 3,
              max: 30,
              divisions: 9,
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
      child: Text(
        'Start',
        style: AppTextTheme.textTheme.titleLarge?.copyWith(
          fontSize: ScaleUtil.fontSize(14),
        ),
      ),
    );
  }
}
