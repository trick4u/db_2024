import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tushar_db/constants/colors.dart';
import 'package:tushar_db/projectController/add_task_controller.dart';

import '../widgets/chip_widgets.dart';

class AddTaskScreen extends GetWidget<AddTaskController> {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Add Task",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.notesMedical),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.fromARGB(255, 251, 196, 204),
              Colors.white,
              //  Colors.green,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //chips
            ChipWidgets(
              addTaskController: controller,
            ),

            // text field
            Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Obx(
                () {
                  return controller.selectedChipIndex != 0
                      ? TextField(
                          controller: controller.goalsController,
                          decoration: InputDecoration(
                            //add shadow
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                            hintText: controller.hintText(),
                            hintStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
                      : SizedBox.shrink();
                },
              ),
            ),

            // save button
            ElevatedButton(
              onPressed: () {
                //controller.addTask();
              },
              child: Text(
                "Save",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            //month task widget
            MonthTaskWidget(),
          ],
        ),
      ),
    );
  }
}

class MonthTaskWidget extends StatelessWidget {
  const MonthTaskWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 400,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Container
          Positioned(
            left: 20,
            child: Container(
              height: 150,
              width: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    ColorsConstants().deepPurple,
                    ColorsConstants().deepPink,
                    ColorsConstants().deepOrange,
                    //  Colors.green,
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    "JANNUARY",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            top: 75,
            right: 20,
            duration: Duration(seconds: 1),
            curve: Curves.easeIn,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 150,
                width: 300,
                padding: EdgeInsets.only(left: 10, top: 30),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: Offset(0, 5),
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.white,
                      ColorsConstants().lightPurple,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  //  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "22",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //check box and text
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Task Completed",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
