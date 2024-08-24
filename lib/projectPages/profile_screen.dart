import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../projectController/profile_controller.dart';
import '../services/app_theme.dart';

class ProfileScreen extends GetWidget<ProfileController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context); // Initialize ScaleUtil

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Obx(() => Text(controller.username.value,
            style: TextStyle(fontSize: ScaleUtil.fontSize(18)))),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            child: Text('Edit',
                style: TextStyle(fontSize: ScaleUtil.fontSize(16))),
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
                      borderRadius: ScaleUtil.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: appTheme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: ScaleUtil.scale(10),
                          spreadRadius: ScaleUtil.scale(1),
                          offset: Offset(0, ScaleUtil.scale(5)),
                        ),
                      ],
                      color: Colors.blue,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
                ScaleUtil.sizedBox(height: 16),
                Obx(
                  () => Text(
                    controller.name.value,
                    style: TextStyle(
                        fontSize: ScaleUtil.fontSize(20),
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Obx(() => Text(controller.email.value ?? '',
                    style: TextStyle(fontSize: ScaleUtil.fontSize(12)),
                    textAlign: TextAlign.center)),
                TextButton(
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: ScaleUtil.fontSize(12),
                    ),
                  ),
                  onPressed: () => _showEditDialog(context),
                ),
              ],
            ),
            // Remaining items in ListView
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchNotifications,
                child: ListView(
                  padding: ScaleUtil.symmetric(horizontal: 16),
                  children: [
                    ScaleUtil.sizedBox(height: 20),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () => appTheme.toggleTheme(),
                      child: Obx(() => Container(
                            padding: ScaleUtil.symmetric(
                                vertical: 12, horizontal: 16),
                            margin: ScaleUtil.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: appTheme.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              borderRadius: ScaleUtil.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'theme',
                                  style: TextStyle(
                                    fontSize: ScaleUtil.fontSize(12),
                                    color: appTheme.isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: ScaleUtil.iconSize(16),
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
                    ScaleUtil.sizedBox(height: 20),
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
        padding: ScaleUtil.symmetric(vertical: 12, horizontal: 16),
        margin: ScaleUtil.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: ScaleUtil.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: ScaleUtil.fontSize(12),
              ),
            ),
            if (isSwitch)
              Switch(
                value: false,
                onChanged: (value) {
                  // Handle switch change
                },
                activeColor: Colors.blue,
              )
            else
              Icon(Icons.arrow_forward_ios, size: ScaleUtil.iconSize(16)),
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
              style: TextStyle(fontSize: ScaleUtil.fontSize(20))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(fontSize: ScaleUtil.fontSize(16)),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16)),
                  onChanged: (value) => newName = value,
                  controller: TextEditingController(text: newName),
                ),
                ScaleUtil.sizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: ScaleUtil.fontSize(16)),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16)),
                  onChanged: (value) => newEmail = value,
                  controller: TextEditingController(text: newEmail),
                ),
                ScaleUtil.sizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(fontSize: ScaleUtil.fontSize(16)),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16)),
                  onChanged: (value) => newUsername = value,
                  controller: TextEditingController(text: newUsername),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                child: Text('Cancel',
                    style: TextStyle(fontSize: ScaleUtil.fontSize(16))),
                onPressed: () => Get.back()),
            TextButton(
              child: Text('Save',
                  style: TextStyle(
                    fontSize: ScaleUtil.fontSize(16),
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
              style: TextStyle(fontSize: ScaleUtil.fontSize(20))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: TextStyle(fontSize: ScaleUtil.fontSize(16)),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16)),
                  obscureText: true,
                  onChanged: (value) => currentPassword = value,
                ),
                ScaleUtil.sizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(fontSize: ScaleUtil.fontSize(16)),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16)),
                  obscureText: true,
                  onChanged: (value) => newPassword = value,
                ),
                ScaleUtil.sizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: TextStyle(fontSize: ScaleUtil.fontSize(16)),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16)),
                  obscureText: true,
                  onChanged: (value) => confirmNewPassword = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16))),
              onPressed: () => Get.back(),
            ),
            TextButton(
              child: Text('Change',
                  style: TextStyle(
                    fontSize: ScaleUtil.fontSize(16),
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
