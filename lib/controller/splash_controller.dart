import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../app_routes.dart';
import '../pages/home_page.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;

  late Animation<Offset> offsetAnimation;

  //animation

  @override
  void onReady() {
    // Future.delayed(Duration(seconds: 2), () {
    //   Get.offNamedUntil(
    //     AppRoutes.MAIN,
    //     (route) => false,
    //   );
    // });
    super.onReady();
  }

  //init
  @override
  void onInit() {

    super.onInit();
  }
}
