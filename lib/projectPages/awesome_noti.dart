import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../services/notification_service.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../services/quotes_service.dart';

class AwesomeNoti extends StatefulWidget {
  const AwesomeNoti({super.key});

  @override
  State<AwesomeNoti> createState() => _AwesomeNotiState();
}

class _AwesomeNotiState extends State<AwesomeNoti> {
  final NotificationController notificationController =
      Get.put(NotificationController());

  OmniDateTimePicker omniDateTimePicker = OmniDateTimePicker(
    onDateTimeChanged: (DateTime dateTime) {
      print(dateTime);
    },
  );
  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationService.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationService.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationService.onDismissActionReceivedMethod,
    );

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      } else {
        print('Notification Allowed');
      }
    });
    //listen for notification

    super.initState();
  }

  void dispose() {
    AwesomeNotifications().dispose();
    super.dispose();
  }

  void scheduleQuoteNotifications() {
    // Schedule the background work using workmanager
    Workmanager().registerPeriodicTask(
      "dailyQuote",
      "fetchAndDisplayQuote",
      frequency: Duration(days: 1),
      initialDelay: Duration(seconds: 10), // Short delay for testing
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      inputData: {
        'hour': 8,
        'minute': 0,
      },
    );
  }

  Future<void> fetchAndDisplayQuote() async {
    String quote = await fetchUniqueRandomQuote();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'quote_channel',
        title: 'Daily Motivation',
        body: quote,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<String> fetchUniqueRandomQuote() async {
    List<String> allQuotes = await QuoteService.fetchQuotes();
    List<String> displayedQuotes = await QuoteService.getDisplayedQuotes();

    // Filter out displayed quotes
    List<String> newQuotes =
        allQuotes.where((quote) => !displayedQuotes.contains(quote)).toList();

    if (newQuotes.isEmpty) {
      // If all quotes have been displayed, reset and use all quotes again
      newQuotes = allQuotes;
      await SharedPreferences.getInstance().then((prefs) {
        prefs.remove(QuoteService.QUOTES_KEY);
      });
    }

    // Get a random quote from the new quotes
    Random random = Random();
    String randomQuote = newQuotes[random.nextInt(newQuotes.length)];

    // Save the displayed quote
    await QuoteService.saveDisplayedQuote(randomQuote);

    return randomQuote;
  }

  // void scheduleQuoteNotifications() {
  //   // Schedule the background work using workmanager
  //   Workmanager().registerPeriodicTask(
  //     "1",
  //     "fetchAndDisplayQuote",
  //     frequency: Duration(minutes: 10),
  //   );
  // }

  void scheduleDailyQuoteNotification() async {
    // Cancel any existing notifications to prevent duplicates
    await AwesomeNotifications().cancelAll();

    // Fetch unique and random quote
    String quote = await fetchUniqueRandomQuote();
    print(quote);

    // Schedule the notification
    // AwesomeNotifications().createNotification(
    //   content: NotificationContent(
    //     id: 1,
    //     channelKey: 'quote_channel',
    //     title: 'Daily Motivation',
    //     body: quote,
    //     notificationLayout: NotificationLayout.Default,
    //   ),
    //   schedule: NotificationCalendar(
    //     hour: 08, // Schedule for 6 AM
    //     minute: 10,
    //     second: 0,
    //     millisecond: 0,
    //     repeats: true,
    //   ),
    // );
  }

  // Future<void> fetchAndDisplayQuote() async {
  //   String quote = await fetchUniqueRandomQuote();
  //   await AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //       id: 1,
  //       channelKey: 'quote_channel',
  //       title: 'Motivation Time!',
  //       body: quote,
  //       notificationLayout: NotificationLayout.Default,
  //     ),
  //   );
  // }

  Future<void> scheduleNotification(
      DateTime scheduledDateTime, String message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: scheduledDateTime.hashCode, // Unique ID
        channelKey: 'basic_channel',
        title: 'Scheduled Reminder 📅',
        body: message,
        notificationLayout: NotificationLayout.BigPicture,
        color: Color(0xFF00FF00),
        backgroundColor: Colors.blue,
        bigPicture:
            'https://cdn.pixabay.com/photo/2024/03/24/17/10/background-8653526_1280.jpg',
      ),
      schedule: NotificationCalendar(
        weekday: scheduledDateTime.weekday,
        hour: scheduledDateTime.hour,
        minute: scheduledDateTime.minute,
        second: 0,
        millisecond: 0,
        allowWhileIdle: true,
        timeZone: AwesomeNotifications.localTimeZoneIdentifier,
      ),
    );
  }

  Future<void> schedulePeriodicNotifications() async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'DoBoara Reminder 📅',
        body: 'Get ahead of your schedule',
        largeIcon:
            'https://cdn.pixabay.com/photo/2024/03/24/17/10/background-8653526_1280.jpg',
        //  icon: "https://cdn.pixabay.com/photo/2023/06/11/01/24/flowers-8055013_1280.jpg",
      ),
      schedule: NotificationCalendar(
        hour: 10,
        minute: 30,
        second: 0,
        millisecond: 0,
        repeats: true,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
      ),
      // actionButtons: [
      //   NotificationActionButton(
      //     key: 'ACTION1',
      //     label: 'Action 1',
      //     actionType: ActionType.Default,
      //   ),
      //   NotificationActionButton(
      //     key: 'ACTION2',
      //     label: 'Action 2',
      //   ),
      // ],

      // schedule: NotificationInterval(
      //     interval: 5 * 60,
      //     timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
      //     repeats: true),
    );
  }

  void pickDateTime() async {
    DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );

    if (dateTime != null) {
      scheduleNotification(dateTime, 'This is your custom scheduled reminder!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              // Awesome Notifications
              pickDateTime();
            },
            child: Text('Awesome Notification'),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              // Awesome Notifications

              schedulePeriodicNotifications();
            },
            child: Text('Periodic Notification'),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              // Awesome Notifications

              scheduleDailyQuoteNotification();
            },
            child: Text('Periodic  quotes Notification'),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              // Awesome Notifications
              notificationController.scheduleQuoteNotifications();
            },
            child: Text('Periodic  quotes Notification'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            notificationController.scheduleQuoteNotifications();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Notifications scheduled every 15 minutes')),
            );
          },
          child: Text('Start Periodic Notifications'),
        ),
        // Container(
        //   alignment: Alignment.center,
        //   child: ElevatedButton(
        //     onPressed: () {
        //       // Awesome Notifications
        //       // schedulePeriodicNotifications();
        //       Workmanager().registerPeriodicTask(
        //         "1",
        //         "periodicNotification ok",
        //         frequency: Duration(minutes: 10),
        //         inputData: {"data": "TusharPeriodicTaskAwesome"},
        //       );

        //       print('Periodic Notification Scheduled');
        //     },
        //     child: Text(' Schedule Periodic Notification'),
        //   ),
        // ),
      ],
    );
  }


}


class NotificationController extends GetxController {
 
  static const platform = MethodChannel('com.example.tushar_db/background_fetch');
 @override
  void onInit() {
    super.onInit();

    if (Platform.isIOS) {
      _setupBackgroundChannel();
    }
  }

  

  void _setupBackgroundChannel() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'fetchAndDisplayQuote') {
        await fetchAndDisplayQuote();
      }
    });
  }

  void scheduleQuoteNotifications() {
    if (Platform.isAndroid) {
      Workmanager().cancelAll();
      Workmanager().registerPeriodicTask(
        "dailyQuote",
        "fetchAndDisplayQuote",
        frequency: Duration(hours: 24),
        initialDelay: Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        inputData: {
          'hour': 9,
          'minute': 30,
        },
      );
    } else if (Platform.isIOS) {
      // For iOS, the scheduling is handled by the system through BGTaskScheduler
      print("Background fetch scheduled for iOS");
    }
  }

  Future<void> fetchAndDisplayQuote() async {
    String quote = await fetchUniqueRandomQuote();
   // await showNotification(quote);
  }



  Future<String> fetchUniqueRandomQuote() async {
    // Implement your logic to fetch a unique random quote
    // This is just a placeholder
    return "Your daily dose of motivation!";
  }

  // For immediate testing
  Future<void> testQuoteNotification() async {
    await fetchAndDisplayQuote();
  }
}



// api key 
// Rp6TdzbMOsLxt45N8sNYdVuP9J6UxkV1u8bQyUj2OIDTl0aeJ4RQfZPN

//api key for pixabay
 //45057779-c29a4dc769b07eac504c6713c