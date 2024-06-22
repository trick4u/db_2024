import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tushar_db/constants/colors.dart';

import '../projectController/page_threeController.dart';
import '../projectPages/awesome_noti.dart';
import '../projectPages/main_screen.dart';

import 'package:popover/popover.dart';

import '../projectPages/page_one.dart';
import '../projectPages/page_three.dart';
import '../projectPages/page_two_calendar.dart';

class MainScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
  //variables
  final RxInt currentIndex = 0.obs;

  final RxList<Widget> pages = [
    Page1(),
    CalendarPage(),
    Page3(),
    AwesomeNoti(),
  ].obs;

  void changePage(
    int index,
    BuildContext context,
  ) {
    currentIndex.value = index;
    if (currentIndex.value == 2) {
      Get.lazyPut<PageThreecontroller>(() => PageThreecontroller());
      showDialog(context);
    } else if (currentIndex.value == 3) {
      Get.lazyPut<AwesomeNoti>(() => AwesomeNoti());
    }
  }

  Color scaffoldBackgroundColor() {
    switch (currentIndex.value) {
      case 0:
        return ColorsConstants().lightPurple;
      case 1:
        return ColorsConstants().lightPink;
      case 2:
        return ColorsConstants().lightOrange;
      case 3:
        return ColorsConstants().lightTeal;
      default:
        return ColorsConstants().lightBlue;
    }
  }

  // if page index ==2 then show dialog
  void showDialog(BuildContext context) {
    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(200, 700, 20, 0),
        popUpAnimationStyle: AnimationStyle(
          curve: Curves.bounceInOut,
          duration: Duration(milliseconds: 500),
          reverseCurve: Curves.linear,
          reverseDuration: Duration(milliseconds: 500),
        ),
        items: [
          PopupMenuItem(
            child: Text('Settings'),
          ),
          PopupMenuItem(
            child: Text('Log Out'),
          ),
        ]);
  }

  //persistent bottom navigation bar
  final List<PersistentBottomNavBarItem> navBarItems = [
    PersistentBottomNavBarItem(
      icon: FontAwesomeIcons.calendarDay,
      title: "Calendar",
      activeColor: ColorsConstants().deepPurple,
      inactiveColor: Colors.grey,
    ),
    PersistentBottomNavBarItem(
      icon: FontAwesomeIcons.rectangleList,
      title: "Tasks",
      activeColor: ColorsConstants().deepPurple,
      inactiveColor: Colors.grey,
    ),
    PersistentBottomNavBarItem(
      icon: FontAwesomeIcons.clock,
      title: "Clock",
      activeColor: ColorsConstants().deepPurple,
      inactiveColor: Colors.grey,
    ),
    PersistentBottomNavBarItem(
      icon: FontAwesomeIcons.user,
      title: "Profile",
      activeColor: ColorsConstants().deepPurple,
      inactiveColor: Colors.grey,
      onTap: () {
        showPopover(
          context: Get.context!,
          bodyBuilder: (context) => const ListItems(),
          onPop: () => print('Popover was popped!'),
          direction: PopoverDirection.top,
          width: 200,
          height: 200,
          arrowHeight: 15,
          arrowWidth: 30,
        );
      },
    ),
  ];
}

class PersistentBottomNavBarItem {
  PersistentBottomNavBarItem({
    required this.icon,
    required this.title,
    required this.activeColor,
    required this.inactiveColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Color activeColor;
  final Color inactiveColor;
  VoidCallback? onTap;
}

//
class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}

class ListItems extends StatelessWidget {
  const ListItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          InkWell(
            onTap: () {},
            child: Container(
              height: 50,
              color: Colors.amber[100],
              child: const Center(child: Text('Entry A')),
            ),
          ),
          const Divider(),
          Container(
            height: 50,
            color: Colors.amber[200],
            child: const Center(child: Text('Entry B')),
          ),
          const Divider(),
          Container(
            height: 50,
            color: Colors.amber[300],
            child: const Center(child: Text('Entry C')),
          ),
        ],
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: GestureDetector(
        child: const Center(child: Text('Click Me')),
        onTap: () {
          showPopover(
            context: context,
            bodyBuilder: (context) => const ListItems(),
            onPop: () => print('Popover was popped!'),
            direction: PopoverDirection.top,
            width: 200,
            height: 200,
            arrowHeight: 15,
            arrowWidth: 30,
          );
        },
      ),
    );
  }
}
