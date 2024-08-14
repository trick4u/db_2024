import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/reminder_model.dart';
import '../projectController/page_one_controller.dart';

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
            subtitle: Text('Time: ${reminder.time} minutes'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => controller.showEditReminderDialog(reminder),
                ),
                Checkbox(
                  value: reminder.isCompleted,
                  onChanged: (bool? value) {
                    controller.toggleReminderCompletion(reminder.id, value ?? false);
                  },
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

  Widget _buildEmptyState() {
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
          Text(
            'Tap "Add Reminders +" to create a new reminder',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
