import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/pages/home_page.dart';

import '../app_routes.dart';
import '../pages/login_page.dart';
import '../projectPages/main_screen.dart';
import 'auth_service.dart';

class AuthWrapper extends StatelessWidget {
  final authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (authService.user.value == null) {
        return MyHomePage();
      }
      
      return FutureBuilder<bool>(
        future: authService.isUserInDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('An error occurred'),
                    ElevatedButton(
                      onPressed: () {
                        // Add retry functionality
                        Get.offNamed(AppRoutes.AUTHWRAPPER);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

        
          return snapshot.data == true ? MainScreen() : MyHomePage();
        },
      );
    });
  }
}