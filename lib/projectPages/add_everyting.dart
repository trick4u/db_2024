import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../projectController/add_everything_controller.dart';

class AddEveryting extends GetWidget<AddEverythingController> {
  const AddEveryting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add Everything',
          style: TextStyle(
              color: Colors.black,
              fontFamily: GoogleFonts.poppins().fontFamily),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            //text
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Add your goals here..',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            //textfield
            TextField(
              controller: controller.goalsController,
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
            //    button
            Obx(() {
              if (controller.text.value.isNotEmpty) {
                return ElevatedButton(
                  onPressed: () {
                    // Define your button action here
                    controller.addGoals(controller.text.value);
                  },
                  child: Text('Submit'),
                );
              } else {
                return SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }
}
