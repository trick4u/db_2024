import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../projectController/displaying_botifications_controller.dart';
import '../services/app_theme.dart';

class DisplayedNotificationsScreen
    extends GetView<DisplayedNotificationsController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Notifications'.toLowerCase()),
        actions: [],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(
             color: Colors.deepPurpleAccent,
          ),);
        } else if (controller.notifications.isEmpty) {
          return Center(child: Text('No notifications'));
        } else {
          return ListView.builder(
            
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              var notification = controller.notifications[index];
              return ListTile(
                title: Text(notification.content?.title ?? 'No title'),
                subtitle: Text(notification.content?.body ?? 'No body'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => controller
                      .cancelNotification(notification.content?.id ?? 0),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
