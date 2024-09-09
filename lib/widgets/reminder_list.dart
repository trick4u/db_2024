import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tushar_db/services/app_text_style.dart';

import '../models/reminder_model.dart';
import '../projectController/page_one_controller.dart';
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
          return ReminderCard(
            reminder: reminder,
            onDelete: () => controller.deleteReminder(reminder.id),
            onEdit: () => _openEditBottomSheet(context, reminder),
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

  Widget _buildEmptyState() {
    final appTheme = Get.find<AppTheme>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: ScaleUtil.iconSize(30),
            color: Colors.grey,
          ),
          ScaleUtil.sizedBox(height: 16),
          Text(
            'No reminders yet',
            style: TextStyle(
              fontSize: ScaleUtil.fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          ScaleUtil.sizedBox(height: 8),
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
                fontSize: ScaleUtil.fontSize(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderCard extends GetView<PageOneController> {
  final ReminderModel reminder;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ReminderCard({
    Key? key,
    required this.reminder,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(reminder.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          _buildActionButton(
            icon: Icons.edit,
            label: 'Edit',
            color: Colors.blue,
            onTap: onEdit,
          ),
          ScaleUtil.sizedBox(width: 4),
          _buildActionButton(
            icon: Icons.delete,
            label: 'Delete',
            color: Colors.red,
            onTap: onDelete,
          ),
        ],
      ),
      child: _buildReminderCardContent(context),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomSlidableAction(
      onPressed: (_) => onTap(),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        width: ScaleUtil.width(50),
        height: ScaleUtil.height(30),
        decoration: BoxDecoration(
          borderRadius: ScaleUtil.circular(8),
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: ScaleUtil.scale(1),
              blurRadius: ScaleUtil.scale(3),
              offset: Offset(0, ScaleUtil.scale(2)),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: ScaleUtil.iconSize(15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCardContent(BuildContext context) {
    return Container(
      margin: ScaleUtil.symmetric(vertical: 8, horizontal: 16),
      child: Obx(() => PressableDough(
            onReleased: (de) => controller.toggleGradientDirectionReminder(),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: ScaleUtil.circular(10),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: ScaleUtil.width(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: controller.isGradientReversedReminder.value
                              ? Alignment.bottomCenter
                              : Alignment.topCenter,
                          end: controller.isGradientReversedReminder.value
                              ? Alignment.topCenter
                              : Alignment.bottomCenter,
                          colors: [
                            Colors.blue,
                            Colors.deepPurpleAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: ScaleUtil.radius(10),
                          bottomLeft: ScaleUtil.radius(10),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: ScaleUtil.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    reminder.reminder,
                                    style: AppTextTheme.textTheme.titleMedium,
                                  ),
                                  ScaleUtil.sizedBox(height: 4),
                                  Text(
                                    'Repeat: ${reminder.repeat ? 'Yes' : 'No'}',
                                    style: TextStyle(
                                      fontSize: ScaleUtil.fontSize(12),
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildDateTimeColumn(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildDateTimeColumn() {
    if (reminder.triggerTime == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'No date set',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScaleUtil.fontSize(12),
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormat('MMM d').format(reminder.triggerTime!),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ScaleUtil.fontSize(12),
          ),
        ),
        ScaleUtil.sizedBox(height: 4),
        Text(
          DateFormat('h:mm a').format(reminder.triggerTime!),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: ScaleUtil.fontSize(10),
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
