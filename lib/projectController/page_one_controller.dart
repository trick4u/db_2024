import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/goals_model.dart';
import 'add_task_controller.dart';

class PageOneController extends GetxController {
  //variables

  // text field controller
  late TextEditingController reminderTextController = TextEditingController();
  RxInt timeSelected = 0.obs;
  var fireStoreInstance = FirebaseFirestore.instance;
  var repeat = false.obs;
  var text = "".obs;

  CollectionReference userGoals =
      FirebaseFirestore.instance.collection('goals').doc().collection('userGoals');

  RxInt carouselPageIndex = 0.obs;
  // Rx<GoalsModel> allGoals = GoalsModel().obs;

  final RxList<GoalsModel> allGoals = RxList<GoalsModel>([]);

  //rx status
  Rx<RxStatus> goalsStatus = RxStatus.loading().obs;

  @override
  void onInit() {
    //   getAllGoals();
    reminderTextController = TextEditingController();
    originalFontColor.value = chips[0].fontColor!;

    originalBackgroundColor = chips[0].backgroundColor as MaterialColor;

    chips[0].fontColor = Colors.black;
    chips[0].backgroundColor = Colors.blue;

    super.onInit();
  }

  //onReady
  @override
  void onReady() {
    getAllGoals();
  }

  @override
  void dispose() {
    reminderTextController.dispose();

    super.dispose();
  }

  // filter days for notification
  var selectedDays = <String>[].obs;

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }

  //get all goals
  void getAllGoals() async {
    goalsStatus.value = RxStatus.loading();
    try {
      // oreder by created at
      fireStoreInstance
          .collection("goals")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("userGoals")
          .orderBy("createdAt", descending: true)
          .snapshots()
          .listen((event) {
        allGoals.clear();
        allGoals.value =
            event.docs.map((e) => GoalsModel.fromJson(e.data())).toList();
      });

      goalsStatus.value = RxStatus.success();
    } catch (e) {
      goalsStatus.value = RxStatus.error(e.toString());
    }
  }

  void scheduleNotifications(String body, int interval, bool repeat) {
    AwesomeNotifications().cancelAll(); // Clear all existing notifications

    for (String day in selectedDays) {
      int weekday = _dayToWeekday(day);

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: weekday, // Unique id for each notification
          channelKey: 'basic_channel',
          title: 'Scheduled Notification',
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          weekday: weekday,
          hour: 21, // Example time, adjust as needed
          minute: 0,
          second: 0,
          millisecond: 0,
          repeats: repeat,
        ),
      );
    }
  }

  int _dayToWeekday(String day) {
    switch (day) {
      case 'Monday':
        return DateTime.monday;
      case 'Tuesday':
        return DateTime.tuesday;
      case 'Wednesday':
        return DateTime.wednesday;
      case 'Thursday':
        return DateTime.thursday;
      case 'Friday':
        return DateTime.friday;
      case 'Saturday':
        return DateTime.saturday;
      case 'Sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
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
        repeats: repeat,
      ),
    );
  }

  void toggleSwitch(bool value) {
    repeat.value = value;
  }

  void setText(String value) {
    text.value = value;
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

  //get goals from firestore
  Stream<QuerySnapshot> getGoals() {
    return fireStoreInstance
        .collection("goals")
        .doc()
        .collection("userGoals")
        .snapshots();
  }

  Future<void> addGoals(GoalsModel goal, ) async {
  User user = FirebaseAuth.instance.currentUser!;
    
    DocumentReference docRef =  fireStoreInstance
        .collection("goals")
        .doc(user.uid)
        .collection("userGoals").doc();
        await docRef.set(goal.toJson(), );
  
   
    print("Document ID: ${docRef.id}");
    Get.back();
  }

  //delete goals
  Future<void> deleteGoal(String docId) async {
    User user = FirebaseAuth.instance.currentUser!;
    
   DocumentSnapshot doc = await fireStoreInstance
        .collection("goals")
        .doc(user.uid)
        .collection("userGoals")
        .doc(docId)
        .get();
    doc.reference.delete();
    
   
  }

  //update goals
  Future<void> updateGoals(String goal, String docId) async {
    await fireStoreInstance
        .collection("goals")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("userGoals")
        .doc(docId)
        .update({
      "goal": goal,
    }).then((_) {
      Get.back();
    });
  }

  //delete goals
  Future<void> deleteGoals(String docId) async {
    try {
     QuerySnapshot querySnapshot = await fireStoreInstance
          .collection("goals")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("userGoals")
          .get();
   for (DocumentSnapshot doc in querySnapshot.docs) {
        doc.reference.delete();
      }

    } catch (e) {
      print(e.toString());
    }
  }

  String getReadableTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
