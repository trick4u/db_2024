import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_task_controller.dart';

class PageOneController extends GetxController {
  //variables

  // text field controller
  late TextEditingController reminderTextController = TextEditingController();
  RxInt timeSelected = 0.obs;
  var fireStoreInstance = FirebaseFirestore.instance;
  var repeat = false.obs;


  @override
  void onInit() {
    reminderTextController = TextEditingController();
    originalFontColor.value = chips[0].fontColor!;

    originalBackgroundColor = chips[0].backgroundColor as MaterialColor;

    chips[0].fontColor = Colors.black;
    chips[0].backgroundColor = Colors.blue;

    super.onInit();
  }

  @override
  void dispose() {
    reminderTextController.dispose();

    super.dispose();
  }

  var chips = <ChipProperties>[
    ChipProperties(
        text: '15 min', fontColor: Colors.white, backgroundColor: Colors.grey),
    ChipProperties(
        text: '30 min', fontColor: Colors.white, backgroundColor: Colors.grey),
    ChipProperties(
        text: '1 hour', fontColor: Colors.white, backgroundColor: Colors.grey),
  ].obs;

  ChipProperties? originalChipProperties;
  var selectedChipIndex = 0.obs;
  var originalFontColor = Colors.white.obs;
  MaterialColor originalBackgroundColor = Colors.blue;

  void updateChipColor(
      int index, Color newFontColor, Color newBackgroundColor) {
    if (index >= 0 && index < chips.length) {
      if (selectedChipIndex.value == index) {
        // Revert to original properties
        chips[index].fontColor = originalFontColor.value;
        chips[index].backgroundColor = originalBackgroundColor;
        selectedChipIndex.value = -1; // Deselect the chip
      } else {
        if (selectedChipIndex.value != -1) {
          // Revert previously selected chip to original properties
          chips[selectedChipIndex.value].fontColor = originalFontColor.value;
          chips[selectedChipIndex.value].backgroundColor =
              originalBackgroundColor;
        }
        // Store the original properties of the new chip
        originalFontColor.value = chips[index].fontColor!;
        originalBackgroundColor = chips[index].backgroundColor as MaterialColor;

        // Update to new properties
        chips[index].fontColor = newFontColor;
        chips[index].backgroundColor = newBackgroundColor;
        selectedChipIndex.value = index; // Select the new chip
      }
      chips.refresh(); // Notify listeners
    }
  }

  Future<void> schedulePeriodicNotifications(
      String body, int interval, bool repeat) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'DoBoara Reminder 📅',
        body: body,
        largeIcon:
            'https://cdn.pixabay.com/photo/2024/03/24/17/10/background-8653526_1280.jpg',
            
      ),
      schedule: NotificationInterval(
          interval: interval * 60,
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          repeats: repeat),
    );
  }

  void toggleSwitch(bool value) {
    repeat.value = value;
  }

  //cancel notification
  Future<void> cancelNotification() async {
    AwesomeNotifications().cancel(10);
  }

  

  //save data into firestore
  Future saveReminder(bool repeat) async {
    await fireStoreInstance
        .collection("reminders")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("userReminders")
        .add({
      "reminder": reminderTextController.text,
      "time": timeSelected.value,
      
      "isReminderSet": true,
      "createdAt": FieldValue.serverTimestamp(),
      "repeat": repeat,
    }).then((_) {
      Get.back();
    });
  }

  //bottom sheet
}
