import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/pages/home_page.dart';

import '../pages/login_page.dart';
import '../projectPages/main_screen.dart';
import 'auth_service.dart';

class AuthWrapper extends StatelessWidget {
  final authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (authService.user.value == null) {
        // User is not authenticated
        return MyHomePage();
      } else {
        // User is authenticated, now check if they're in the database
        return FutureBuilder<bool>(
          future: authService.isUserInDatabase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('An error occurred'),
                ),
              );
            } else if (snapshot.data == true) {
              // User is in the database, navigate to MainScreen
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.offAll(() => MainScreen(),);
              });
              return Container(
                color: Colors.white,
              );
            } else {
              // User is not in the database, they need to complete profile
              return MyHomePage();
            }
          },
        );
      }
    });
  }
}
