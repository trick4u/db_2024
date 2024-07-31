import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';

import '../projectController/profile_controller.dart';
import '../services/app_theme.dart';

class ProfileScreen extends GetWidget<ProfileController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
  // var controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            child: Text('Edit', style: TextStyle()),
            onPressed: () {
              // Handle edit action
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            //container
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
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
            Text(
              'Blake Gordon',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Obx(() => Text(
                  controller.email.value ?? '',
                )),
            TextButton(
              child: Text('Edit', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                // Handle edit action
              },
            ),
            Spacer(),
            _buildOptionTile('Show me as away', isSwitch: true),
            _buildOptionTile('Theme', onTap: () {
              // Handle vision board action
              appTheme.toggleTheme();
            }),
            _buildOptionTile('Vision board', onTap: () {
              // Handle vision board action
              Get.toNamed(AppRoutes.VISIONBOARD);
            }),
            _buildOptionTile(
              'logout',
              onTap: () {
                controller.logout();
                print('Logged out');
              },
            ),
            _buildOptionTile(
              'delete account',
              onTap: () {
                controller.deleteAccount();

                print('Logged out and account deleted');
              },
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    String title, {
    bool isSwitch = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
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
              Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
