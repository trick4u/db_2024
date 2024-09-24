
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/network_controller.dart';

class NetworkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NetworkController networkController = Get.find<NetworkController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Network Connectivity'),
      ),
      body: Center(
        child: Obx(() {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  networkController.checkNetworkConnectivity();
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'You are ${networkController.isOnline.value ? 'online' : 'offline'}',
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tap to check connectivity',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          );
        }),
      ),
    );
  }
}