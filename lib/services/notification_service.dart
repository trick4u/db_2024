import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';

import '../app_routes.dart';
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
    // Convert ReceivedNotification to ReceivedAction
    final receivedAction = ReceivedAction(
    
    );
    Get.find<NotificationTrackingService>().trackDisplayedNotification(receivedAction);
  }

  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Handle notification dismissal
    print('Notification dismissed: ${receivedAction.id}');
    
  }
}