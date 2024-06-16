import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PageThreecontroller extends GetxController {
  var count = 0.obs;
  increment() => count++;

  RxString text = 'tushar'.obs;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void onInit() {
    super.onInit();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid, iOS: null, macOS: null);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // handle the received notification here
  }

  Future onSelectNotification(String payload) async {
    // handle the notification tapped logic here
  }

  Future<void> scheduleNotification(DateTime scheduledTime) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Scheduled Notification',
      'This is the notification body',
      scheduledTime,
      platformChannelSpecifics,
    );
  }
}
