import 'package:get/get.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class NotificationTrackingService extends GetxService {
  final RxList<ReceivedAction> displayedNotifications = <ReceivedAction>[].obs;
  final GetStorage _box = GetStorage();
  final String _storageKey = 'displayed_notifications';

  Future<NotificationTrackingService> init() async {
    await loadDisplayedNotifications();
    print('NotificationTrackingService initialized with ${displayedNotifications.length} notifications');
    return this;
  }

  Future<void> trackDisplayedNotification(ReceivedAction action) async {
    print('Tracking notification: ${action.title}');
    // Check if the notification is already tracked to avoid duplicates
    if (!displayedNotifications.any((element) => element.id == action.id)) {
      displayedNotifications.add(action);
      await saveDisplayedNotifications();
      print('Notification tracked. Total: ${displayedNotifications.length}');
    } else {
      print('Notification already tracked');
    }
  }

  Future<void> removeDisplayedNotification(int id) async {
    print('Removing notification with id: $id');
    displayedNotifications.removeWhere((action) => action.id == id);
    await saveDisplayedNotifications();
    print('Notification removed. Total: ${displayedNotifications.length}');
  }

  Future<void> clearAllDisplayedNotifications() async {
    print('Clearing all notifications');
    displayedNotifications.clear();
    await saveDisplayedNotifications();
    print('All notifications cleared');
  }

  Future<void> saveDisplayedNotifications() async {
    final List<Map<String, dynamic>> notificationsData = 
      displayedNotifications.map((action) => action.toMap()).toList();
    await _box.write(_storageKey, json.encode(notificationsData));
    print('Saved ${notificationsData.length} notifications to storage');
  }

  Future<void> loadDisplayedNotifications() async {
    final String? encodedData = _box.read(_storageKey);
    if (encodedData != null) {
      final List<dynamic> decodedData = json.decode(encodedData);
      displayedNotifications.assignAll(
        decodedData.map((item) => ReceivedAction().fromMap(item as Map<String, dynamic>)).toList(),
      );
      print('Loaded ${displayedNotifications.length} notifications from storage');
    } else {
      print('No notifications found in storage');
    }
  }
}