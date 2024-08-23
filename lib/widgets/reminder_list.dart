import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/reminder_model.dart';
import '../projectController/page_one_controller.dart';
import '../services/app_text_style.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';
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
            title: Text(
              reminder.reminder,
              style: AppTextTheme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Time: ${reminder.time} minutes',
              style: AppTextTheme.textTheme.bodyMedium,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: ScaleUtil.scale(24)),
                  onPressed: () => controller.showEditReminderDialog(reminder),
                ),
                SizedBox(
                  width: ScaleUtil.scale(24),
                  height: ScaleUtil.scale(24),
                  child: Checkbox(
                    value: reminder.isCompleted,
                    onChanged: (bool? value) {
                      controller.toggleReminderCompletion(
                          reminder.id, value ?? false);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: ScaleUtil.scale(24)),
                  onPressed: () => controller.deleteReminder(reminder.id),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    final appTheme = Get.find<AppTheme>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: ScaleUtil.scale(64),
            color: Colors.grey,
          ),
          SizedBox(height: ScaleUtil.height(16)),
          Text(
            'No reminders yet',
            style: AppTextTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: ScaleUtil.height(8)),
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
              style: AppTextTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
