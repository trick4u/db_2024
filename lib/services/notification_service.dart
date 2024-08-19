import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';

import '../app_routes.dart';
import '../projectController/calendar_controller.dart';
import 'notification_tracking_service.dart';

class NotificationService  extends GetxController{
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Handle notification action
    print('Notification action received: ${receivedAction.id}');
    //navigate to a page
      Get.toNamed(AppRoutes.MAIN);


  }

  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Handle notification creation
    print('Notification created: ${receivedNotification.id}');
  }

   static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Handle notification display
    print('Notification displayed: ${receivedNotification.id}');
    
   if (receivedNotification.id != null) {
      Get.find<CalendarController>().markNotificationAsDisplayed(receivedNotification.id!);
    }
    // Use the received notification directly
   // Get.find<NotificationTrackingService>().trackDisplayedNotification(receivedNotification);
  }

  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Handle notification dismissal
    print('Notification dismissed: ${receivedAction.id}');
    
  }
}