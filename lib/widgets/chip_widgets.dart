import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/projectController/add_task_controller.dart';

import '../constants/colors.dart';

class ChipWidgets extends StatelessWidget {
  final AddTaskController addTaskController;

  const ChipWidgets({
    required this.addTaskController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    List.generate(addTaskController.chips.length, (index) {
                  var chip = addTaskController.chips[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                      onTap: () {
                      
                        addTaskController.updateChipColor(
                          index,
                          Colors.white,
                          Colors.blue,
                        );
                      },
                      child: Chip(
                        label: Text(
                          chip.text ?? '',
                          style: TextStyle(color: chip.fontColor),
                        ),
                        backgroundColor: chip.backgroundColor,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: Colors.transparent,
                            width: 0,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}
