import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/colors.dart';
import '../controller/main_screen_controller.dart';

class MainScreen extends GetWidget<MainScreenController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                ColorsConstants().deepPurple,
                Colors.purple,
              ],
            ),
          ),
          child: Icon(
            Icons.add,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() => controller.pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() => Container(
            height: 80,
            decoration: BoxDecoration(
              //border radius
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),

              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 6,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: controller.navBarItems
                        .sublist(0, 2)
                        .map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: IconButton(
                                onPressed: () => controller.changePage(
                                  controller.navBarItems.indexOf(item),
                                  context,
                                ),
                                icon: Icon(
                                  item.icon,
                                  color: controller.currentIndex.value ==
                                          controller.navBarItems.indexOf(item)
                                      ? item.activeColor
                                      : null,
                                ),
                              ),
                            ))
                        .toList(),

                    // Row 2
                  ),
                  Row(
                    children: controller.navBarItems
                        .sublist(2, 4)
                        .map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: IconButton(
                                onPressed: () => controller.changePage(
                                  controller.navBarItems.indexOf(item),
                                  context,
                                ),
                                icon: Icon(
                                  item.icon,
                                  color: controller.currentIndex.value ==
                                          controller.navBarItems.indexOf(item)
                                      ? item.activeColor
                                      : null,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: controller.navBarItems
              //       .map((item) => IconButton(
              //             onPressed: () => controller.changePage(
              //               controller.navBarItems.indexOf(item),
              //               context,
              //             ),
              //             icon: Icon(
              //               item.icon,
              //               color: controller.currentIndex.value ==
              //                       controller.navBarItems.indexOf(item)
              //                   ? item.activeColor
              //                   : null,
              //             ),
              //           ))
              //       .toList(),
              // ),
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
