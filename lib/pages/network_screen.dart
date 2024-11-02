import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/network_controller.dart';
import '../services/scale_util.dart';

class NetworkStatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NetworkController networkController = Get.find<NetworkController>();
    return GetX<NetworkController>(
      builder: (controller) {
        return AnimatedSlide(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          // When online, slide down (1 = fully off screen), when offline slide up (0 = visible)
          offset: Offset(0, controller.isOnline.value ? 1 : 0),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            // Hide completely when online
            opacity: controller.isOnline.value ? 0.0 : 1.0,
            child: Material(
              elevation: 4,
              child: Container(
                width: double.infinity,
                height: ScaleUtil.height(30),
                color: Colors.red.shade700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: ScaleUtil.height(16),
                    ),
                    SizedBox(width: ScaleUtil.width(8)),
                    Text(
                      'No Internet Connection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScaleUtil.fontSize(12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
