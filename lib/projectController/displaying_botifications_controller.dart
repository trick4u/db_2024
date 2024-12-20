import 'package:get/get.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../services/notification_tracking_service.dart';
import '../services/toast_util.dart';

class DisplayedNotificationsController extends GetxController {
  final NotificationTrackingService _trackingService =
      Get.find<NotificationTrackingService>();
  RxList<ReceivedAction> get displayedNotifications =>
      _trackingService.displayedNotifications;
  RxBool isLoading = false.obs;

  RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  //awesome notifications
  Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
      ToastUtil.showToast('Success', 'All notifications have been cancelled');
      fetchNotifications();
    } catch (error) {
      ToastUtil.showToast('Error', 'Failed to cancel notifications: $error');
    }
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      List<NotificationModel> fetchedNotifications =
          await AwesomeNotifications().listScheduledNotifications();
      notifications.assignAll(fetchedNotifications);
    } catch (error) {
      print('Error fetching notifications: $error');
      ToastUtil.showToast('Error', 'Failed to fetch notifications: $error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await AwesomeNotifications().cancel(id);
      await fetchNotifications(); // Refresh the list
      ToastUtil.showToast('Success', 'Notification cancelled');
    } catch (error) {
      ToastUtil.showToast('Error', 'Failed to cancel notification: $error');
    }
  }
}
