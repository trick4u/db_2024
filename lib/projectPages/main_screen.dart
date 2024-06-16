import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/main_screen_controller.dart';

class MainScreen extends GetWidget<MainScreenController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: Obx(() => controller.pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() => Padding(
            padding: const EdgeInsets.all(8.0),
            child: BottomNavigationBar(
              items: controller.navBarItems
                  .map((item) => BottomNavigationBarItem(
                        icon: Icon(item.icon),
                        label: item.title,
                        activeIcon: Icon(item.icon, color: item.activeColor),
                      ))
                  .toList(),
              currentIndex: controller.currentIndex.value,
              onTap: (index) => controller.changePage(
                index,
                context,
              ),
            ),
          )),
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Page'),
    );
  }
}



