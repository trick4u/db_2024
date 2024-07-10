import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../projectController/three_tasks_controller.dart';

class ThreeTasksScreen extends GetWidget<ThreeTasksController> {
  const ThreeTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9C4),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Obx(() => Text("Plan your ${controller.timeOfDay.value}")),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // text
              SizedBox(
                height: 20,
              ),
              Obx(() => Text(
                    "Add 3 tasks for ${controller.timeOfDay.value} ",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontFamily: "Euclid"),
                  )),
              // 3 text fields with filled property set to true
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: controller.task1Controller,
                onChanged: (value) {
                  controller.task1.value = value;
                },
                decoration: InputDecoration(
                  hintText: 'Task 1',
                  filled: true,
                  border: InputBorder.none,
                  fillColor: Colors.white,
                  enabledBorder: InputBorder.none,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: controller.task2Controller,
                onChanged: (value) {
                  controller.task2.value = value;
                },
                decoration: InputDecoration(
                  hintText: 'Task 2',
                  filled: true,
                  border: InputBorder.none,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                autocorrect: true,
                controller: controller.task3Controller,
                onChanged: (value) {
                  controller.task3.value = value;
                },
                decoration: InputDecoration(
                  hintText: 'Task 3',
                  filled: true,
                  border: InputBorder.none,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // button
              ElevatedButton(
                onPressed: () {
                  controller.saveTasks(controller.timeOfDay.value);
                },
                child: Text('Save Tasks'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
