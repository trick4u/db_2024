import 'package:get/get.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../services/notification_tracking_service.dart';

class DisplayedNotificationsController extends GetxController {
  final NotificationTrackingService _trackingService =
      Get.find<NotificationTrackingService>();
  RxList<ReceivedAction> get displayedNotifications =>
      _trackingService.displayedNotifications;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDisplayedNotifications();
  }

  Future<void> fetchDisplayedNotifications() async {
    isLoading.value = true;
    try {
      await _trackingService.loadDisplayedNotifications();
      print('Fetched ${displayedNotifications.length} notifications');
    
    } catch (error) {
      print('Error fetching displayed notifications: $error');
      Get.snackbar('Error', 'Failed to fetch notifications');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> dismissNotification(int id) async {
    try {
      await AwesomeNotifications().cancel(id);
      await _trackingService.removeDisplayedNotification(id);
      print('Dismissed notification with id: $id');
      Get.snackbar('Success', 'Notification dismissed');
    } catch (error) {
      print('Error dismissing notification: $error');
      Get.snackbar('Error', 'Failed to dismiss notification');
    }
  }

  Future<void> dismissAllNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
      await _trackingService.clearAllDisplayedNotifications();
      print('Dismissed all notifications');
      Get.snackbar('Success', 'All notifications have been dismissed');
    } catch (error) {
      print('Error dismissing all notifications: $error');
      Get.snackbar('Error', 'Failed to dismiss notifications');
    }
  }
}
