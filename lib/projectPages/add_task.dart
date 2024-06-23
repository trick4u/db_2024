import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/projectController/add_task_controller.dart';

class AddTaskScreen extends GetWidget<AddTaskController> {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // stack wisget
            Container(
              height: 500,
              child: Stack(
                fit: StackFit.loose,
                children: [
                  // top container
                  Obx(() {
                    return AnimatedPositioned(
                      top: 100.0,
                      left: controller.isTopMoved.value ? 200.0 : 100.0,
                      duration: Duration(milliseconds: 500),
                      child: GestureDetector(
                        onTap: controller.moveTopRight,
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.red,
                          child: Center(
                            child: Text('Top'),
                          ),
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: controller.moveBottomRight,
                    child: Positioned(
                      top: 100.0,
                      left: 100.0,
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.blue,
                        child: Center(
                          child: Text('Bottom'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
