import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../projectController/profile_controller.dart';
import '../services/app_theme.dart';

class ProfileScreen extends GetView<ProfileController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Obx(() => Text(controller.username.value)),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            child: Text('Edit', style: TextStyle()),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Static blue container
            Column(
              children: [
                Padding(
                  padding: ScaleUtil.symmetric(vertical: 15),
                  child: Container(
                    height: ScaleUtil.height(200),
                    width: ScaleUtil.width(200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: appTheme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: Offset(0, 5),
                        ),
                      ],
                      color: Colors.blue,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Obx(
                  () => Text(
                    controller.name.value,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Obx(() => Text(controller.email.value ?? '',
                    textAlign: TextAlign.center)),
                TextButton(
                  child: Text('Edit', style: TextStyle(color: Colors.blue)),
                  onPressed: () => _showEditDialog(context),
                ),
              ],
            ),
            // Remaining items in ListView
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchNotifications,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    SizedBox(height: 20),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () => appTheme.toggleTheme(),
                      child: Obx(() => Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: appTheme.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'theme',
                                  style: TextStyle(
                                    color: appTheme.isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: appTheme.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ],
                            ),
                          )),
                    ),
                    _buildOptionTile('change password',
                        onTap: () => _showChangePasswordDialog(context)),
                    _buildOptionTile('logout',
                        onTap: () => controller.logout()),
                    _buildOptionTile('delete account',
                        onTap: () => controller.deleteAccount()),
                    SizedBox(height: 20),
                    Obx(() {
                      if (controller.isLoading.value) {
                        return Center(child: CircularProgressIndicator());
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
                              title: Text(
                                  notification.content?.title ?? 'No title'),
                              subtitle:
                                  Text(notification.content?.body ?? 'No body'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => controller.cancelNotification(
                                    notification.content?.id ?? 0),
                              ),
                            );
                          },
                        );
                      }
                    }),
                    SizedBox(height: 20),
                    ElevatedButton(
                      child: Text('Cancel All Notifications'),
                      onPressed: () => controller.cancelAllNotifications(),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: appTheme.colorScheme.onPrimary,
                        backgroundColor: appTheme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title,
      {bool isSwitch = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            if (isSwitch)
              Switch(
                value: false,
                onChanged: (value) {
                  // Handle switch change
                },
                activeColor: Colors.blue,
              )
            else
              Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = controller.name.value;
        String newEmail = controller.email.value;
        String newUsername = controller.username.value;

        return AlertDialog(
          title: Text('Edit Profile',
              style: Theme.of(context).textTheme.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    border: OutlineInputBorder(),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  onChanged: (value) => newName = value,
                  controller: TextEditingController(text: newName),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    border: OutlineInputBorder(),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  onChanged: (value) => newEmail = value,
                  controller: TextEditingController(text: newEmail),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    border: OutlineInputBorder(),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  onChanged: (value) => newUsername = value,
                  controller: TextEditingController(text: newUsername),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                child: Text('Cancel',
                    style: Theme.of(context).textTheme.bodyMedium),
                onPressed: () => Get.back()),
            TextButton(
              child: Text('Save',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      )),
              onPressed: () async {
                Navigator.of(context).pop();
                bool anyChanges = false;

                if (newName != controller.name.value) {
                  await controller.updateName(newName);

                  anyChanges = true;
                }

                if (newEmail != controller.email.value) {
                  await controller.updateEmail(newEmail);

                  anyChanges = true;
                }

                if (newUsername != controller.username.value) {
                  await controller.updateUsername(newUsername);

                  anyChanges = true;
                }

                if (!anyChanges) {}
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    String currentPassword = '';
    String newPassword = '';
    String confirmNewPassword = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password',
              style: Theme.of(context).textTheme.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    border: OutlineInputBorder(),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  obscureText: true,
                  onChanged: (value) => currentPassword = value,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    border: OutlineInputBorder(),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  obscureText: true,
                  onChanged: (value) => newPassword = value,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    border: OutlineInputBorder(),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  obscureText: true,
                  onChanged: (value) => confirmNewPassword = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child:
                  Text('Cancel', style: Theme.of(context).textTheme.bodyMedium),
              onPressed: () => Get.back(),
            ),
            TextButton(
              child: Text('Change',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      )),
              onPressed: () {
                if (newPassword != confirmNewPassword) {
                  Get.snackbar('Error', 'New passwords do not match');
                  return;
                }
                controller.changePassword(currentPassword, newPassword);
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}
