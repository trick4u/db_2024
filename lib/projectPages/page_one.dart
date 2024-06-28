import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../projectController/page_one_controller.dart';
import '../widgets/quick_reminder_chips.dart';
import '../widgets/rounded_rect_container.dart';

class PageOneScreen extends GetWidget<PageOneController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      alignment: Alignment.center,
      //  child: RoundedGradientContainer(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Page 1',
            style: TextStyle(fontSize: 30),
          ),
          const SizedBox(height: 20),
          // text quick task
          InkWell(
            onTap: () {
              // bottom sheet
              showBottomSheet();
            },
            child: const Text(
              'Quick Task',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  void showBottomSheet() {
    Get.bottomSheet(
      Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          // border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Quick Reminder',
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 20),
              const Text(
                'Remind me about',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller.reminderTextController,
                onChanged: (value) {},
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Task Name',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remind me after',
                    style: TextStyle(fontSize: 20),
                  ),
                  Obx(() => Text(
                        'Switch is ${controller.repeat.value ? "ON" : "OFF"}',
                      )),
                  // checkbox
                  Obx(() => Switch(
                        value: controller.repeat.value,
                        onChanged: (value) {
                          controller.toggleSwitch(value);
                        },
                      )),
                ],
              ),
              const SizedBox(height: 20),
              // 3 chips
              ChipWidgets(
                pageOneController: controller,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (controller.timeSelected.value == 1) {
                    controller.schedulePeriodicNotifications(
                        controller.reminderTextController.text,
                        15,
                        controller.repeat.value);
                  } else if (controller.timeSelected.value == 2) {
                    controller.schedulePeriodicNotifications(
                        controller.reminderTextController.text,
                        30,
                        controller.repeat.value);
                  } else if (controller.timeSelected.value == 3) {
                    controller.schedulePeriodicNotifications(
                        controller.reminderTextController.text,
                        60,
                        controller.repeat.value);
                  }
                  //save the reminder into firestore
                  controller.saveReminder(controller.repeat.value);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
