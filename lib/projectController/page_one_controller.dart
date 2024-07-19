import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/goals_model.dart';
import '../projectPages/awesome_noti.dart';
import '../services/notification_service.dart';
import 'add_task_controller.dart';

class PageOneController extends GetxController {
  //variables

  // text field controller
  late TextEditingController reminderTextController = TextEditingController();
  RxInt timeSelected = 0.obs;
  var fireStoreInstance = FirebaseFirestore.instance;
  var repeat = false.obs;
  var text = "".obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var goalsList = <Goals>[].obs;

  User? get currentUser => _auth.currentUser;

  RxInt carouselPageIndex = 0.obs;
  // Rx<GoalsModel> allGoals = GoalsModel().obs;

  final RxList<GoalsModel> allGoals = RxList<GoalsModel>([]);

  //rx status
  Rx<RxStatus> goalsStatus = RxStatus.loading().obs;

  var greeting = ''.obs;

  //pomodor timer
  var isRunning = false.obs;
  var isBreak = false.obs;
  var seconds = 0.obs;
  var workDuration = 25 * 60; // 25 minutes
  var breakDuration = 5 * 60; // 5 minutes
  late AudioPlayer audioPlayer;
  final Color startColor = Color(0xFF2196F3);
  final Color endColor = Color(0xFFF44336);
  late Timer _colorTimer;
  var backgroundColor = Color(0xFF2196F3).obs;

  @override
  void onInit() {
    //   getAllGoals();

    audioPlayer = AudioPlayer();
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
    //getAllGoals();
    fetchGoals();
    updateGreeting();
    _initializeColorAnimation();
    fetchMorningTasks();
  }

  @override
  void dispose() {
    reminderTextController.dispose();
    audioPlayer.dispose();

    super.dispose();
  }

  //increase volume

  void _initializeColorAnimation() {
    _colorTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isRunning.value) {
        double progress = (workDuration - seconds.value) / workDuration;
        backgroundColor.value = Color.lerp(startColor, endColor, progress)!;
      }
    });
  }

  void increaseVolume() {
    audioPlayer.setVolume(10);
  }

  void startTimer() async {
    isRunning.value = true;
    seconds.value = isBreak.value ? breakDuration : workDuration;
    var audioUrl =
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3'; // YouTube video ID
    audioPlayer.setUrl(audioUrl);
    //increase volume of audio
    increaseVolume();

    audioPlayer.play();
    _timerTick();
  }

  void _timerTick() {
    if (seconds.value > 0) {
      Future.delayed(Duration(seconds: 1), () {
        if (isRunning.value) {
          seconds.value--;
          _timerTick();
        }
      });
    } else {
      _onTimerComplete();
    }
  }

  void _onTimerComplete() {
    isRunning.value = false;
    isBreak.value = !isBreak.value;
    audioPlayer.stop();
  }

  void stopTimer() {
    isRunning.value = false;
    audioPlayer.stop();
  }

  void updateGreeting() {
    final now = DateTime.now();
    if (now.hour >= 5 && now.hour < 12) {
      greeting.value = 'Good Morning';
    } else if (now.hour >= 12 && now.hour < 17) {
      greeting.value = 'Good Afternoon';
    } else {
      greeting.value = 'Good Evening';
    }
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
          channelKey: 'quick_reminder',
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
        channelKey: 'quickschedule',
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
  void fetchGoals() async {
    goalsStatus.value = RxStatus.loading();
    try {
      if (currentUser != null) {
        var snapshot = await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('goals')
            .get();
        goalsList.value = snapshot.docs
            .map((doc) =>
                Goals.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        goalsStatus.value = RxStatus.success();
      }
    } catch (e) {
      goalsStatus.value = RxStatus.error(e.toString());

      print(e);
    }
  }

  void addGoal(String goal) async {
    if (currentUser != null) {
      var docRef = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('goals')
          .add({
        'goal': goal,
        'createdTime': Timestamp.now(),
      });
      goalsList
          .add(Goals(id: docRef.id, goal: goal, createdTime: Timestamp.now()));
    }
  }

  void updateGoal(String id, String newGoal) async {
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('goals')
          .doc(id)
          .update({'goal': newGoal});
      var index = goalsList.indexWhere((goal) => goal.id == id);
      if (index != -1) {
        goalsList[index] = Goals(
            id: id, goal: newGoal, createdTime: goalsList[index].createdTime);
        goalsList.refresh(); // Notify GetX to update the UI
      }
    }
  }

  void deleteGoal(String id) async {
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('goals')
          .doc(id)
          .delete();
      goalsList.removeWhere((goal) => goal.id == id);
    }
  }

  String getReadableTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  //fetch morning tasks
  void fetchMorningTasks() async {
    try {
      var snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('Morning')
          .get();
      print(snapshot.docs);
    } catch (e) {
      print(e);
    }
  }
}
