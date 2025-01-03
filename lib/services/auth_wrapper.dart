import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/pages/home_page.dart';

import '../app_routes.dart';
import '../pages/login_page.dart';
import '../projectPages/main_screen.dart';
import 'auth_service.dart';
import 'shimmer_loading.dart';

class AuthWrapper extends StatelessWidget {
  final authService = Get.find<AuthService>();
  static const int timeoutDuration = 10;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return FutureBuilder<bool>(
        future: _checkAuthStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: ShimmerLoading(),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Unable to connect. Please try again.'),
                    ElevatedButton(
                      onPressed: () {
                        Get.offNamed(AppRoutes.AUTHWRAPPER);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Default to MyHomePage if anything goes wrong
          final isAuthenticated = snapshot.data ?? false;
          return isAuthenticated ? MainScreen() : MyHomePage();
        },
      );
    });
  }

  Future<bool> _checkAuthStatus() async {
    try {
      if (authService.user.value == null) return false;

      // Add timeout to prevent infinite waiting
      final isInDb = await authService.isUserInDatabase()
          .timeout(const Duration(seconds: timeoutDuration));
      
      return isInDb;
    } catch (e) {
      debugPrint('Auth check error: $e');
      return false;
    }
  }
}
