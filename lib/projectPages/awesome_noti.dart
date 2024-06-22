import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class AwesomeNoti extends StatefulWidget {
  const AwesomeNoti({super.key});

  @override
  State<AwesomeNoti> createState() => _AwesomeNotiState();
}

class _AwesomeNotiState extends State<AwesomeNoti> {
  
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



   Future<void> scheduleNotification(DateTime scheduledDateTime, String message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: scheduledDateTime.hashCode, // Unique ID
        channelKey: 'basic_channel',
        title: 'Scheduled Reminder',
        body: message,
        notificationLayout: NotificationLayout.BigPicture,
        color: Color(0xFF00FF00),
        backgroundColor: Colors.blue,
        bigPicture: 'https://cdn.pixabay.com/photo/2024/03/24/17/10/background-8653526_1280.jpg',
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
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          // Awesome Notifications
          pickDateTime();
        
        },
        child: Text('Awesome Notification'),
      ),
    );
  }
}
