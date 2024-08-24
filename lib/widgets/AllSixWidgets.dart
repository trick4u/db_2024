import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';

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

  final List<Map<String, dynamic>> items = [
    {'title': 'Daily journal', 'icon': FontAwesomeIcons.book},
    {'title': 'Take notes', 'icon': FontAwesomeIcons.noteSticky},
    {'title': 'All reminders', 'icon': FontAwesomeIcons.listCheck},
    {'title': 'Completed tasks', 'icon': FontAwesomeIcons.checkDouble},
    {'title': 'Upcoming', 'icon': FontAwesomeIcons.calendarDay},
    {'title': 'Vision', 'icon': FontAwesomeIcons.eye},
    {'title': 'Pending', 'icon': FontAwesomeIcons.clock},
    {'title': 'Add Reminders', 'icon': FontAwesomeIcons.plus},
  ];
  final RxString selectedTile = ''.obs;

  void _initializeSelectedTile() {
    final List<String> autoSelectTiles = [
      'upcoming',
      'pending',
      'completed tasks'
    ];
    final random = Random();
    selectedTile.value =
        autoSelectTiles[random.nextInt(autoSelectTiles.length)];
    onListTypeSelected(selectedTile.value);
  }

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
    ScaleUtil.init(context);
    _initializeSelectedTile();
    Widget gridView = GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: ScaleUtil.width(8.0),
        mainAxisSpacing: ScaleUtil.height(8.0),
        childAspectRatio: 3.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Obx(() => InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                String tileTitle = items[index]['title']!.toLowerCase();
                selectedTile.value = tileTitle;
                if (tileTitle == 'pending' ||
                    tileTitle == 'upcoming' ||
                    tileTitle == 'completed tasks' ||
                    tileTitle == 'all reminders') {
                  onListTypeSelected(tileTitle);
                } else if (tileTitle == 'add reminders') {
                  showQuickReminderBottomSheet();
                } else if (tileTitle == 'daily journal') {
                  Get.toNamed(AppRoutes.JOURNAL);
                } else if (tileTitle == 'take notes') {
                  Get.toNamed(AppRoutes.NOTETAKING);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: ScaleUtil.circular(10),
                  border:
                      selectedTile.value == items[index]['title']!.toLowerCase()
                          ? Border.all(
                              color: Colors.deepPurpleAccent,
                              width: ScaleUtil.scale(2))
                          : null,
                  color:
                      selectedTile.value == items[index]['title']!.toLowerCase()
                          ? Colors.white
                          : Colors.deepPurpleAccent,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      items[index]['title']!.toLowerCase(),
                      style: AppTextTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: ScaleUtil.fontSize(14),
                        color: selectedTile.value ==
                                items[index]['title']!.toLowerCase()
                            ? Colors.deepPurpleAccent
                            : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (items[index]['icon'] != null) ...[
                      ScaleUtil.sizedBox(width: 8),
                      FaIcon(
                        items[index]['icon'],
                        size: ScaleUtil.iconSize(12),
                        color: selectedTile.value ==
                                items[index]['title']!.toLowerCase()
                            ? Colors.deepPurpleAccent
                            : Colors.white,
                      ),
                    ]
                  ],
                ),
              ),
            ));
      },
    );

    if (useFixedHeight) {
      return SizedBox(
        height:
            height ?? ScaleUtil.height(200), // Default height if not provided
        child: gridView,
      );
    } else {
      return gridView;
    }
  }

  void showBottomSheet() {
    final appTheme = AppTheme();
    final reminderController = Get.find<PageOneController>();

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
                  borderRadius:
                      BorderRadius.vertical(top: ScaleUtil.radius(20)),
                ),
                child: Padding(
                  padding: ScaleUtil.symmetric(horizontal: 15),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      ScaleUtil.sizedBox(height: 20),
                      Text(
                        'Quick Reminder',
                        style: appTheme.titleLarge
                            .copyWith(fontSize: ScaleUtil.fontSize(20)),
                        textAlign: TextAlign.center,
                      ),
                      ScaleUtil.sizedBox(height: 20),
                      Text(
                        'Remind me about',
                        style: appTheme.bodyMedium
                            .copyWith(fontSize: ScaleUtil.fontSize(16)),
                      ),
                      ScaleUtil.sizedBox(height: 20),
                      ClipRRect(
                        borderRadius: ScaleUtil.circular(10),
                        child: TextField(
                          controller: reminderController.reminderTextController,
                          onChanged: (value) {},
                          style: appTheme.bodyMedium
                              .copyWith(fontSize: ScaleUtil.fontSize(16)),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Enter Task Name',
                            labelStyle:
                                TextStyle(fontSize: ScaleUtil.fontSize(14)),
                            fillColor: appTheme.textFieldFillColor,
                            filled: true,
                          ),
                        ),
                      ),
                      ScaleUtil.sizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remind me after',
                            style: appTheme.bodyMedium
                                .copyWith(fontSize: ScaleUtil.fontSize(16)),
                          ),
                          Obx(() => Text(
                                'Switch is ${reminderController.repeat.value ? "ON" : "OFF"}',
                                style: appTheme.bodyMedium
                                    .copyWith(fontSize: ScaleUtil.fontSize(14)),
                              )),
                          Obx(() => Switch(
                                value: reminderController.repeat.value,
                                onChanged: (value) {
                                  reminderController.toggleSwitch(value);
                                },
                              )),
                        ],
                      ),
                      ScaleUtil.sizedBox(height: 20),
                      ChipWidgets(
                        pageOneController: reminderController,
                      ),
                      ScaleUtil.sizedBox(height: 20),
                      Obx(() {
                        return Wrap(
                          spacing: ScaleUtil.width(8.0),
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
                              label: Text(day,
                                  style: appTheme.bodyMedium.copyWith(
                                      fontSize: ScaleUtil.fontSize(14))),
                              selected: isSelected,
                              onSelected: (_) =>
                                  reminderController.toggleDay(day),
                              backgroundColor: appTheme.cardColor,
                              selectedColor: appTheme.colorScheme.primary,
                            );
                          }).toList(),
                        );
                      }),
                      ScaleUtil.sizedBox(height: 20),
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
                                color: appTheme.colorScheme.onPrimary,
                                fontSize: ScaleUtil.fontSize(16))),
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
