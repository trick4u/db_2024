import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/projectController/page_one_controller.dart';

class ChipWidgets extends StatelessWidget {
  final PageOneController pageOneController;

  const ChipWidgets({
    required this.pageOneController,
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
                    List.generate(pageOneController.chips.length, (index) {
                  var chip = pageOneController.chips[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                      onTap: () {
                        pageOneController.updateChipColor(
                          index,
                          Colors.white,
                          Colors.blue,
                        );
                        // update time selected value
                        pageOneController.timeSelected.value = index + 1;
                        if (pageOneController.selectedChipIndex.value == 0) {
                          pageOneController.timeSelected.value = 1;
                        } else if (pageOneController.selectedChipIndex.value ==
                            1) {
                          pageOneController.timeSelected.value = 2;
                        } else if (pageOneController.selectedChipIndex.value ==
                            2) {
                          pageOneController.timeSelected.value = 3;
                        }
                        print(
                            "Time Selected: ${pageOneController.timeSelected.value}");
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
