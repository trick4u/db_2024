import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../projectController/displaying_botifications_controller.dart';
import '../services/app_theme.dart';

class DisplayedNotificationsScreen extends GetView<DisplayedNotificationsController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Displayed Notifications'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.fetchDisplayedNotifications,
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          } else if (controller.displayedNotifications.isEmpty) {
            return Center(child: Text('No displayed notifications'));
          } else {
            return RefreshIndicator(
              onRefresh: controller.fetchDisplayedNotifications,
              child: ListView.builder(
                itemCount: controller.displayedNotifications.length,
                itemBuilder: (context, index) {
                  var notification = controller.displayedNotifications[index];
                  return ListTile(
                    title: Text(notification.title ?? 'No title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.body ?? 'No body'),
                        if (notification.payload != null && notification.payload!.isNotEmpty)
                          Text('Payload: ${notification.payload}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => controller.dismissNotification(notification.id ?? 0),
                    ),
                  );
                },
              ),
            );
          }
        }),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.clear_all),
        onPressed: controller.dismissAllNotifications,
        tooltip: 'Dismiss all notifications',
      ),
    );
  }
}