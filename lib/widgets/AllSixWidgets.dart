import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../projectController/page_one_controller.dart';
import '../services/app_text_style.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';
import 'quick_bottomsheet.dart';
import 'quick_reminder_chips.dart';

class AllSixCards extends GetWidget<PageOneController> {
  final appTheme = Get.find<AppTheme>();
  final double? height;
  final bool useFixedHeight;
  final Function(String) onListTypeSelected;

  AllSixCards({
    this.height,
    this.useFixedHeight = false,
    required this.onListTypeSelected,
  });

  final List<Map<String, String>> items = [
    {'title': 'Daily journal'},
    {'title': 'Take notes'},
    {'title': 'All reminders'},
    {'title': 'Completed tasks'},
    {'title': 'Upcoming'},
    {'title': 'Vision'},
    {'title': 'Pending'},
    {'title': 'Add Reminders +'},
  ];
  final RxString selectedTile = ''.obs;

  void showQuickReminderBottomSheet() {
    final reminderController = Get.find<PageOneController>();

    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return QuickReminderBottomSheet(
          reminderController: reminderController,
          appTheme: appTheme,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget gridView = GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 3.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Obx(() => InkWell(
              onTap: () {
                String tileTitle = items[index]['title']!.toLowerCase();
                selectedTile.value = tileTitle;
                if (tileTitle == 'pending' ||
                    tileTitle == 'upcoming' ||
                    tileTitle == 'completed tasks' ||
                    tileTitle == 'all reminders') {
                  onListTypeSelected(tileTitle);
                } else if (tileTitle == 'add reminders +') {
                  showQuickReminderBottomSheet();
                } else {
                  // Handle other tile taps here
                  print('Tapped on: ');
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:
                      selectedTile.value == items[index]['title']!.toLowerCase()
                          ? Colors.deepPurple
                          : Colors.deepPurpleAccent,
                ),
                alignment: Alignment.center,
                child: Text(
                  items[index]['title']!.toLowerCase(),
                  style: AppTextTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ));
      },
    );

    if (useFixedHeight) {
      return SizedBox(
        height: height ?? 200, // Default height if not provided
        child: gridView,
      );
    } else {
      return gridView;
    }
  }

  void showBottomSheet() {
    final appTheme = AppTheme();
    final reminderController = Get.find<
        PageOneController>(); // Replace with your actual controller name

    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
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
                      ClipRRect(
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
                      ),
                      const SizedBox(height: 20),
                      Row(
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
                      ),
                      const SizedBox(height: 20),
                      ChipWidgets(
                        pageOneController: reminderController,
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
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
                            final isSelected =
                                reminderController.selectedDays.contains(day);
                            return FilterChip(
                              label: Text(day, style: appTheme.bodyMedium),
                              selected: isSelected,
                              onSelected: (_) =>
                                  reminderController.toggleDay(day),
                              backgroundColor: appTheme.cardColor,
                              selectedColor: appTheme.colorScheme.primary,
                            );
                          }).toList(),
                        );
                      }),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (reminderController.timeSelected.value == 1) {
                            reminderController.schedulePeriodicNotifications(
                                reminderController.reminderTextController.text,
                                15,
                                reminderController.repeat.value);
                          } else if (reminderController.timeSelected.value ==
                              2) {
                            reminderController.schedulePeriodicNotifications(
                                reminderController.reminderTextController.text,
                                30,
                                reminderController.repeat.value);
                          } else if (reminderController.timeSelected.value ==
                              3) {
                            reminderController.schedulePeriodicNotifications(
                                reminderController.reminderTextController.text,
                                60,
                                reminderController.repeat.value);
                          }
                          reminderController
                              .saveReminder(reminderController.repeat.value);
                          Get.back();
                        },
                        style: appTheme.primaryButtonStyle,
                        child: Text('Save',
                            style: appTheme.bodyMedium.copyWith(
                                color: appTheme.colorScheme.onPrimary)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
