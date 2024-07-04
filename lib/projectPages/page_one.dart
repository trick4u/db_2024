import 'package:animate_do/animate_do.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dough/dough.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tushar_db/constants/colors.dart';

import '../models/goals_model.dart';
import '../projectController/page_one_controller.dart';
import '../widgets/four_boxes.dart';
import '../widgets/goals_box.dart';
import '../widgets/quick_reminder_chips.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';

import '../widgets/three_shaped_box.dart';

class PageOneScreen extends GetWidget<PageOneController> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //text page 1

            const Text(
              'Page 1',
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 20),
            // rounded rect container
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              child: CarouselSlider(
                key: UniqueKey(),
                slideTransform: CubeTransform(),
                unlimitedMode: false,
                initialPage: 0,
                onSlideChanged: (int index) {
                  controller.carouselPageIndex.value = index;
                },
                children: [
                  ThreeShapedBox(),
                  FourBoxes(),
                  ThreeDayTasks(),
                  GoalsContainer(),
                ],
              ),
            ),
            SizedBox(height: 20),
            Obx(
              () {
                if (controller.carouselPageIndex.value == 0) {
                  return Text(
                    'Morning Tasks',
                    style: TextStyle(fontSize: 20),
                  );
                } else {
                  return Container();
                }
              },
            ),
            Obx(
              () => controller.carouselPageIndex.value == 0 ||
                      controller.carouselPageIndex.value == 2
                  ? PageOneBottomPart()
                  : Container(),
            ),
            InkWell(
              onTap: () {
                // bottom sheet
                showBottomSheet();
              },
              child: const Text(
                'Quick Task',
                style: TextStyle(fontSize: 20),
              ),
            ),

            // text quick task
          ],
        ),
      ),
    );
  }

  void showBottomSheet() {
    Get.bottomSheet(
      Container(
        // height: 900,
        decoration: BoxDecoration(
          color: Colors.white,
          // border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Quick Reminder',
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Remind me about',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller.reminderTextController,
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Task Name',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remind me after',
                      style: TextStyle(fontSize: 20),
                    ),
                    Obx(() => Text(
                          'Switch is ${controller.repeat.value ? "ON" : "OFF"}',
                        )),
                    // checkbox
                    Obx(() => Switch(
                          value: controller.repeat.value,
                          onChanged: (value) {
                            controller.toggleSwitch(value);
                          },
                        )),
                  ],
                ),
                const SizedBox(height: 20),
                // 3 chips
                ChipWidgets(
                  pageOneController: controller,
                ),
                const SizedBox(height: 20),
                Obx(() {
                  return Wrap(
                    spacing: 8.0,
                    children: [
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                      'Saturday',
                      'Sunday'
                    ].map((day) {
                      final isSelected = controller.selectedDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (_) => controller.toggleDay(day),
                      );
                    }).toList(),
                  );
                }),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    controller.scheduleNotifications(
                        controller.reminderTextController.text, 15, true);
                    // if (controller.timeSelected.value == 1) {
                    //   controller.schedulePeriodicNotifications(
                    //       controller.reminderTextController.text,
                    //       15,
                    //       controller.repeat.value);
                    // } else if (controller.timeSelected.value == 2) {
                    //   controller.schedulePeriodicNotifications(
                    //       controller.reminderTextController.text,
                    //       30,
                    //       controller.repeat.value);
                    // } else if (controller.timeSelected.value == 3) {
                    //   controller.schedulePeriodicNotifications(
                    //       controller.reminderTextController.text,
                    //       60,
                    //       controller.repeat.value);
                    // }
                    // //save the reminder into firestore
                    // controller.saveReminder(controller.repeat.value);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThreeDayTasks extends StatelessWidget {
  const ThreeDayTasks({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // 3 equal parts
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: FadeInDownBig(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Text(
                      'Morning Tasks',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: SlideInRight(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Text(
                      'Afternoon Tasks',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: FadeInUp(
                  delay: Duration(milliseconds: 500),
                  duration: Duration(milliseconds: 100),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Text(
                        'Evening Tasks',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageOneBottomPart extends GetWidget<PageOneController> {
  const PageOneBottomPart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PressableDough(
        child: AnimatedSize(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              //shadow
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Obx(() {
              if (controller.goalsStatus.value.isLoading) {
                return CircularProgressIndicator();
              } else if (controller.goalsStatus.value.isSuccess) {
                return ListView.builder(
                  itemCount: controller.goalsList.length,
                  itemBuilder: (context, index) {
                    var goal = controller.goalsList[index];

                    return ListTile(
                      title: Text(
                        controller.goalsList.elementAt(index).goal ?? "",
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: IconButton(
                        icon: Icon(
                          FontAwesomeIcons.edit,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          controller.updateGoal(goal.id, goal.goal ?? "");
                        },
                      ),

                      trailing: IconButton(
                        icon: Icon(
                          FontAwesomeIcons.trash,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          controller.deleteGoal(goal.id ?? "");
                        },
                      ),
                      subtitle: Text(
                        controller.getReadableTime(
                            controller.goalsList.elementAt(index).createdTime ??
                                Timestamp.now()),
                        style: TextStyle(color: Colors.white),
                      ),
                      //  subtitle: Text(),
                    );
                  },
                );
              } else {
                return Text("unable to load goals");
              }
            }),
          ),
        ),
      ),
    );
  }
}


// ListView.builder(
//                 itemCount: controller.allGoals.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(
//                       controller.allGoals.elementAt(index).goal ?? "",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     //  subtitle: Text(),
//                   );
//                 },
//               ),