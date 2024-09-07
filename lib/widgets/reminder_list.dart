import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/reminder_model.dart';
import '../projectController/page_one_controller.dart';
import '../services/app_theme.dart';
import 'quick_bottomsheet.dart';

class RemindersList extends GetWidget<PageOneController> {
  const RemindersList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.allReminders.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        itemCount: controller.allReminders.length,
        itemBuilder: (context, index) {
          final reminder = controller.allReminders[index];
          return ListTile(
            title: Text(reminder.reminder),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trigger time: ${_formatDateTime(reminder.triggerTime)}'),
                Text('Repeat: ${reminder.repeat ? 'Yes' : 'No'}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _openEditBottomSheet(context, reminder),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => controller.deleteReminder(reminder.id),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  void _openEditBottomSheet(BuildContext context, ReminderModel reminder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return QuickReminderBottomSheet(
          reminderController: controller,
          appTheme: Get.find<AppTheme>(),
          reminderToEdit: reminder,
        );
      },
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Not set';
    }
    return DateFormat('MMM d, y HH:mm').format(dateTime);
  }

  Widget _buildEmptyState() {
    final appTheme = Get.find<AppTheme>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No reminders yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: Get.context!,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return QuickReminderBottomSheet(
                    reminderController: controller,
                    appTheme: appTheme,
                  );
                },
              );
            },
            child: Text(
              'Tap "add reminders +" to create a new reminder',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}