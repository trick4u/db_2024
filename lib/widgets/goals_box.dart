import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tushar_db/app_routes.dart';

import '../projectController/page_one_controller.dart';

class GoalsContainer extends GetWidget<PageOneController> {
  const GoalsContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goals',
              style: TextStyle(
                fontSize: 25,
                //  fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                FontAwesomeIcons.plus,
                color: Colors.black,
              ),
              onPressed: () {
                //  print('Add Everything');
                // Get.toNamed(AppRoutes.ADDEVERYTHING);

                Get.bottomSheet(
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Add your goals here..',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.times,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: controller.reminderTextController,
                          maxLines: 10,
                          onChanged: (value) {
                            controller.setText(value);
                          },
                          focusNode: FocusNode(),
                          decoration: InputDecoration(
                            hintText: 'Enter your goals here..',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            controller.addGoals(controller.text.value);
                            Get.back();
                          },
                          child: Text('Add'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
