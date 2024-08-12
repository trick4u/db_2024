



import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../projectController/page_one_controller.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';
import 'quick_reminder_chips.dart';

class QuickReminderBottomSheet extends StatelessWidget {
  final PageOneController reminderController;
  final AppTheme appTheme;

  const QuickReminderBottomSheet({
    Key? key,
    required this.reminderController,
    required this.appTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ScaleUtil.symmetric(horizontal: 10),
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: appTheme.cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: ListView(
                controller: scrollController,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Quick Reminder',
                    style: appTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Remind me about',
                    style: appTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(),
                  const SizedBox(height: 20),
                  _buildRepeatSwitch(),
                  const SizedBox(height: 20),
                  ChipWidgets(
                    pageOneController: reminderController,
                  ),
                  const SizedBox(height: 20),
                  _buildDaySelector(),
                  SizedBox(height: 20),
                  _buildSaveButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TextField(
        controller: reminderController.reminderTextController,
        onChanged: (value) {},
        style: appTheme.bodyMedium,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: 'Enter Task Name',
          fillColor: appTheme.textFieldFillColor,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildRepeatSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Remind me after',
          style: appTheme.bodyMedium,
        ),
        Obx(() => Text(
              'Switch is ${reminderController.repeat.value ? "ON" : "OFF"}',
              style: appTheme.bodyMedium,
            )),
        Obx(() => Switch(
              value: reminderController.repeat.value,
              onChanged: (value) {
                reminderController.toggleSwitch(value);
              },
            )),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Obx(() {
      return Wrap(
        spacing: 8.0,
        children: [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ].map((day) {
          final isSelected = reminderController.selectedDays.contains(day);
          return FilterChip(
            label: Text(day, style: appTheme.bodyMedium),
            selected: isSelected,
            onSelected: (_) => reminderController.toggleDay(day),
            backgroundColor: appTheme.cardColor,
            selectedColor: appTheme.colorScheme.primary,
          );
        }).toList(),
      );
    });
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        _handleSave();
        Get.back();
      },
      style: appTheme.primaryButtonStyle,
      child: Text('Save',
          style: appTheme.bodyMedium.copyWith(
              color: appTheme.colorScheme.onPrimary)),
    );
  }

  void _handleSave() {
    int minutes;
    switch (reminderController.timeSelected.value) {
      case 1:
        minutes = 15;
        break;
      case 2:
        minutes = 30;
        break;
      case 3:
        minutes = 60;
        break;
      default:
        minutes = 15;
    }
    reminderController.schedulePeriodicNotifications(
      reminderController.reminderTextController.text,
      minutes,
      reminderController.repeat.value,
    );
    reminderController.saveReminder(reminderController.repeat.value);
  }
}