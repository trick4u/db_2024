import 'package:flutter/material.dart';
import 'package:get/get.dart';



import '../projectPages/main_screen.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;

  late Animation<Offset> offsetAnimation;

  //animation

  @override
  void onReady() {
    Future.delayed(Duration(seconds: 2), () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.offAll(() => MainScreen(),);
              });
    });
    super.onReady();
  }

  //init
  @override
  void onInit() {

    super.onInit();
  }
}
