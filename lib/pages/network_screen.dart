
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
        child:  Obx(() {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You are ${networkController.isOnline.value ? 'online' : 'offline'}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
            
            ],
          );
        }),
      ),
    );
  }
}
