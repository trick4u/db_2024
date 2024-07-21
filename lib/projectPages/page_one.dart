import 'package:animate_do/animate_do.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dough/dough.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';
import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/constants/colors.dart';
import 'package:tushar_db/services/app_text_style.dart';

import '../controller/theme_controller.dart';
import '../models/goals_model.dart';
import '../projectController/page_one_controller.dart';
import '../projectController/pomodoro_controller.dart';
import '../widgets/four_boxes.dart';
import '../widgets/goals_box.dart';
import '../widgets/quick_reminder_chips.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';

import '../widgets/three_day.dart';
import '../widgets/three_shaped_box.dart';
import 'main_screen.dart';

class PageOneScreen extends GetWidget<PageOneController> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //text page 1

            Obx(() => Text(
                  '${controller.greeting}',
                  style: AppTextStyles.heading1,
                )),
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
              () {
                if (controller.carouselPageIndex.value == 0) {
                  return PageOneBottomPart();
                } else if (controller.carouselPageIndex.value == 1) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => JustCheck());
                        },
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.pink,
                          child: Column(
                            children: [
                              Text("Just Check"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (controller.carouselPageIndex.value == 2) {
                  return InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.EATTHEFROG);
                    },
                    child: Container(
                      height: 200,
                      color: Colors.green,
                      alignment: Alignment.center,
                      child: Text("eat the frog"),
                    ),
                  );
                } else if (controller.carouselPageIndex.value == 3) {
                  return Obx(() => AnimatedContainer(
                        height: 200,
                        duration: Duration(seconds: 1),
                        color: controller.backgroundColor.value,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Obx(() => Text(
                                  controller.isBreak.value
                                      ? 'Break Time'
                                      : 'Work Time',
                                  style: TextStyle(fontSize: 24),
                                )),
                            Obx(() => Text(
                                  '${(controller.seconds.value / 60).floor().toString().padLeft(2, '0')}:${(controller.seconds.value % 60).toString().padLeft(2, '0')}',
                                  style: TextStyle(fontSize: 48),
                                )),
                            SizedBox(height: 20),
                            Obx(() => ElevatedButton(
                                  onPressed: controller.isRunning.value
                                      ? controller.stopTimer
                                      : controller.startTimer,
                                  child: Text(controller.isRunning.value
                                      ? 'Stop'
                                      : 'Start'),
                                )),
                          ],
                        ),
                      ));
                } else {
                  return Container();
                }
              },
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
                    if (controller.timeSelected.value == 1) {
                      controller.schedulePeriodicNotifications(
                          controller.reminderTextController.text,
                          15,
                          controller.repeat.value);
                    } else if (controller.timeSelected.value == 2) {
                      controller.schedulePeriodicNotifications(
                          controller.reminderTextController.text,
                          30,
                          controller.repeat.value);
                    } else if (controller.timeSelected.value == 3) {
                      controller.schedulePeriodicNotifications(
                          controller.reminderTextController.text,
                          60,
                          controller.repeat.value);
                    }
                    // //save the reminder into firestore
                    controller.saveReminder(controller.repeat.value);
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
                          // bottom sheet
                          _showBottomSheet(context);
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

  void _showBottomSheet(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  focusNode: FocusNode(),
                  decoration: InputDecoration(
                    labelText: 'Enter text',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Handle save or submit action
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ],
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

class JustCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAB and Bottom Sheet Interaction'),
      ),
      body: Stack(
        children: [
          Center(
            child: Text(
              'Press the FAB to reveal the container',
              style: TextStyle(fontSize: 18),
            ),
          ),
          GetBuilder<MyController>(
            init: MyController(),
            builder: (controller) {
              return AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                left: 20,
                right: 20,
                top: controller.isExpanded
                    ? 100
                    : MediaQuery.of(context).size.height - 80,
                bottom: controller.isExpanded ? 130 : 20,
                child: Container(
                  padding: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: controller.isExpanded
                      ? Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Expanded Container',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: controller.toggleExpand,
                                  child: Text('Close'),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => RegistryCheck());
                                  },
                                  child: Text('Registry check'),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => LoginPage());
                                    },
                                    child: Text('Login check')),
                                ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => MainScreenOne());
                                    },
                                    child: Text("Pomodoro check")),
                                ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => PomodoroView());
                                    },
                                    child: Text("Main Screen check")),
                                ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => CustomPaintedContainer());
                                    },
                                    child: Text("Noise check")),
                              ],
                            ),
                          ),
                        )
                      : Icon(Icons.add, color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: GetBuilder<MyController>(
        builder: (controller) {
          return controller.isFabExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: AnimatedContainer(
                    duration: Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    width: 200,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: controller.toggleFabExpand,
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            controller.toggleExpand();
                          },
                          child: Text(
                            'Expanded FAB',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : AnimatedContainer(
                  duration: Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  width: 60,
                  height: 60,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    onPressed: () {
                      controller.toggleFabExpand();
                    },
                    icon: Icon(Icons.add, color: Colors.white),
                  ),
                );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class MyController extends GetxController {
  bool isExpanded = false;

  bool isFabExpanded = false;

  void toggleExpand() {
    isExpanded = !isExpanded;
    update();
  }

  void toggleFabExpand() {
    isFabExpanded = !isFabExpanded;
    update();
  }
}

class RegistryCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Eat The Frog'),
      ),
      body: Center(
        child: CustomCard(),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.deepPurple[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                child: ShapeOfView(
                  height: 500,
                  elevation: 4,
                  shape: DiagonalShape(
                    position: DiagonalPosition.Bottom,
                    direction: DiagonalDirection.Left,
                    angle: DiagonalAngle.deg(angle: 10),
                  ),
                  child: Container(
                    color: Colors.purpleAccent,
                    // child: Image.network(
                    //   'https://example.com/illustration.png',
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Organize it all with Estaro',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'A task manager you can trust for life',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
        Positioned(
          bottom: 50,
          child: GlowingButton(),
        ),
      ],
    );
  }
}

class GlowingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.5),
            spreadRadius: 10,
            blurRadius: 20,
          ),
        ],
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          backgroundColor: Colors.purpleAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Create New Task',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello Again!',
              ),
              SizedBox(height: 8.0),
              Text(
                'Welcome back you\'ve been missed!',
                //
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter username',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: Icon(Icons.visibility, color: Colors.white70),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Recovery Password',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text('Sign In'),
              ),
              SizedBox(height: 16.0),
              Text('Or continue with',
                  style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.account_circle, color: Colors.white70),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.account_circle, color: Colors.white70),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.account_circle, color: Colors.white70),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Register now',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: themeController.toggleTheme,
        child: Icon(Icons.brightness_6),
      ),
    );
  }
}

class PomodoroView extends StatelessWidget {
  final PomodoroController controller = Get.put(PomodoroController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Get.isDarkMode ? Colors.black : Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Text(
                    controller.currentMode.value,
                    style: TextStyle(
                        fontSize: 24,
                        color: Get.isDarkMode ? Colors.white : Colors.black),
                  )),
              SizedBox(height: 20),
              Obx(() => CustomPaint(
                    painter: CircleProgressPainter(
                      progress: 1 - (controller.timeLeft.value / (25 * 60)),
                      color: controller.currentMode.value == 'FOCUS'
                          ? Colors.red
                          : Colors.blue,
                    ),
                    child: Container(
                      width: 300,
                      height: 300,
                      child: Center(
                        child: Text(
                          '${(controller.timeLeft.value ~/ 60).toString().padLeft(2, '0')}:${(controller.timeLeft.value % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                              fontSize: 48,
                              color:
                                  Get.isDarkMode ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                  )),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Obx(() => Container(
                        width: 10,
                        height: 10,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < controller.currentRound.value
                              ? (controller.currentMode.value == 'FOCUS'
                                  ? Colors.red
                                  : Colors.blue)
                              : Colors.grey,
                        ),
                      )),
                ),
              ),
              SizedBox(height: 20),
              Obx(() => ElevatedButton(
                    onPressed: controller.isRunning.value
                        ? controller.pauseTimer
                        : controller.startTimer,
                    child: Icon(controller.isRunning.value
                        ? Icons.pause
                        : Icons.play_arrow),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      backgroundColor: controller.currentMode.value == 'FOCUS'
                          ? Colors.red
                          : Colors.blue,
                      padding: EdgeInsets.all(20),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreenOneController extends GetxController {
  var progressTodayTask = 0.65.obs;
  var todayTasksCompleted = 4.obs;
  var todayTasksTotal = 9.obs;
  var inProgressTasksCompleted = 2.obs;
  var inProgressTasksTotal = 5.obs;
}

class MainScreenOne extends StatelessWidget {
  final MainScreenOneController controller = Get.put(MainScreenOneController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.search, color: Colors.white),
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/150'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Greeting
              Text(
                'Hi, Marie Taylor',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Progress Today Task
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress Today Task',
                        style: TextStyle(color: Colors.white)),
                    SizedBox(height: 10),
                    // Obx(() => CircularPercentIndicator(
                    //       radius: 60.0,
                    //       lineWidth: 5.0,
                    //       percent: controller.progressTodayTask.value,
                    //       center: Text(
                    //         '${(controller.progressTodayTask.value * 100).toInt()}%',
                    //         style: TextStyle(color: Colors.white),
                    //       ),
                    //       progressColor: Colors.white,
                    //       backgroundColor: Colors.grey,
                    //     )),
                    SizedBox(height: 10),
                    Obx(() => Text(
                          '${controller.todayTasksCompleted}/${controller.todayTasksTotal} Tasks Completed',
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Task Summary
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Today\'s Task',
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 10),
                          Obx(() => Text(
                                '${controller.todayTasksCompleted}/${controller.todayTasksTotal} Done',
                                style: TextStyle(color: Colors.white),
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('In Progress',
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 10),
                          Obx(() => Text(
                                '${controller.inProgressTasksCompleted}/${controller.inProgressTasksTotal} Tasks',
                                style: TextStyle(color: Colors.white),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // My Task Section
              Text(
                'My Task',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Task Cards
              Expanded(
                child: ListView(
                  children: [
                    TaskCard(
                      title: 'Food App UX Research',
                      time: 'Today 10:30am - 12:45pm',
                      description:
                          'Identify common use cases and scenarios for ordering food.',
                      color: Colors.pink,
                      completed: true,
                    ),
                    TaskCard(
                      title: 'Food App Wireframing',
                      time: 'Today 1:00pm - 3:00pm',
                      description: 'Create wireframes for the food app.',
                      color: Colors.green,
                      completed: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String time;
  final String description;
  final Color color;
  final bool completed;

  TaskCard({
    required this.title,
    required this.time,
    required this.description,
    required this.color,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(time, style: TextStyle(color: Colors.white)),
          SizedBox(height: 10),
          Text(description, style: TextStyle(color: Colors.white)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              completed
                  ? Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 5),
                        Text('Done', style: TextStyle(color: Colors.white)),
                      ],
                    )
                  : Container(),
              Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}
