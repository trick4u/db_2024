import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';

import '../projectController/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  var controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    return Scaffold(
      backgroundColor: Color(0xFF181923),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            child: Text('Edit', style: TextStyle(color: Colors.blue)),
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'blake@email.com',
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
              child: Text('Edit', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                // Handle edit action
              },
            ),
            Spacer(),
            _buildOptionTile('Show me as away', isSwitch: true),
            _buildOptionTile('Theme'),
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
            InkWell(
              onTap: () {
                controller.deleteAccount();
              },
              child: _buildOptionTile(
                'delete account',
              ),
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
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: Colors.white)),
            if (isSwitch)
              Switch(
                value: false,
                onChanged: (value) {
                  // Handle switch change
                },
                activeColor: Colors.blue,
              )
            else
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
