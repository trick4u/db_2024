import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';

import '../projectController/profile_controller.dart';
import '../services/app_theme.dart';

class ProfileScreen extends GetWidget<ProfileController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Container(
                height: 200,
                width: 200,
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
              SizedBox(height: 16),
              Obx(
                () => Text(
                  controller.name.value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Obx(() => Text(controller.email.value ?? '')),
              TextButton(
                child: Text('Edit', style: TextStyle(color: Colors.blue)),
                onPressed: () => _showEditDialog(context),
              ),
              Spacer(),
              InkWell(
                splashColor: Colors.transparent,
                onTap: () => appTheme.toggleTheme(),
                child: Obx(() => Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color:
                            appTheme.isDarkMode ? Colors.white : Colors.black,
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
              _buildOptionTile('vision board',
                  onTap: () => Get.toNamed(AppRoutes.VISIONBOARD)),
              _buildOptionTile('logout', onTap: () => controller.logout()),
              _buildOptionTile('delete account',
                  onTap: () => controller.deleteAccount()),
              SizedBox(height: 20),
            ],
          ),
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
}
