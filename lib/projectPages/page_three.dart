import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../app_routes.dart';
import '../main.dart';
import '../projectController/page_threeController.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

// class LocalNotifications extends StatefulWidget {
//   const LocalNotifications({super.key});

//   @override
//   State<LocalNotifications> createState() => _LocalNotificationsState();
// }

// class _LocalNotificationsState extends State<LocalNotifications> {
//   void showNotification() async {
//     AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//         "notifications-youtube", "YouTube Notifications",
//         priority: Priority.max, importance: Importance.max);

//     DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     NotificationDetails notiDetails =
//         NotificationDetails(android: androidDetails, iOS: iosDetails);

//     DateTime scheduleDate = DateTime.now().add(Duration(seconds: 5));

//     await notificationsPlugin.zonedSchedule(
//         0,
//         "Sample Notification",
//         "This is a notification",
//         tz.TZDateTime.from(scheduleDate, tz.local),
//         notiDetails,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.wallClockTime,
//         androidAllowWhileIdle: true,
//         payload: "notification-payload");
//   }

//   void checkForNotification() async {
//     NotificationAppLaunchDetails? details =
//         await notificationsPlugin.getNotificationAppLaunchDetails();

//     if (details != null) {
//       if (details.didNotificationLaunchApp) {
//         NotificationResponse? response = details.notificationResponse;

//         if (response != null) {
//           String? payload = response.payload;
//           log("Notification Payload: $payload");
//         }
//       }
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     checkForNotification();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: showNotification,
//         child: Icon(Icons.notification_add),
//       ),
//       body: SafeArea(
//         child: Container(),
//       ),
//     );
//   }
// }
// FlutterLocalNotificationsPlugin notificationsPlugin =
//     FlutterLocalNotificationsPlugin();

class Page3 extends StatefulWidget {
  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  //permission for notification
  void requestPermission() async {
    PermissionStatus status = await Permission.notification.request();

    if (status.isGranted) {
      log("Permission Granted");
    } else {
      log("Permission Denied");
    }
  }

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  void showNotification(DateTime localTime) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        "notifications-youtube", "YouTube Notifications",
        priority: Priority.max, importance: Importance.max);

    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    //on select notification
    notificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestCriticalPermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (details) {
        onSelectNotification(details.payload);
      },
    );

    NotificationDetails notiDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    // DateTime scheduleDate = DateTime.now().add(Duration(seconds: 5));

    await notificationsPlugin.zonedSchedule(
        0,
        "Sample Notification",
        "This is a notification",
        tz.TZDateTime.from(localTime, tz.local),
        notiDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true,
        payload: "notification-payload");

    //for ios
  }

  void checkForNotification() async {
    NotificationAppLaunchDetails? details =
        await notificationsPlugin.getNotificationAppLaunchDetails();

    if (details != null) {
      if (details.didNotificationLaunchApp) {
        NotificationResponse? response = details.notificationResponse;

        if (response != null) {
          String? payload = response.payload;
          log("Notification Payload: $payload");
        }
      }
    }
  }

  //cancel notification

  void cancelNotification() async {
    await notificationsPlugin.cancel(0);
  }

  //on select notification function for android

  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      Get.toNamed(AppRoutes.MAIN);
      log("Notification Payload: $payload");
    }
  }

  //date time picker

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        selectedDate =
            DateTime.now().add(Duration(minutes: selectedDate.minute));
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
        selectedDate = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, selectedTime.hour, selectedTime.minute);

        print("Selected Date: $selectedDate");
      });

      // cupertino timne picker
      
  }

  @override
  void initState() {
    // TODO: implement initState
    checkForNotification();
   requestPermission();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            _selectTime(context);
          },
          child: Text('Select Date'),
        ),
        TextButton(
          onPressed: () => cancelNotification(),
          child: Text('Cancel Notification'),
        ),
        Center(
            child: GestureDetector(
          onTap: () async {
            //open date picker
             showNotification(selectedDate);
       

          },
          child: Text('Notification Scheduled'),
        )),
      ],
    );
  }
}
