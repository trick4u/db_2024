import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTaskController extends GetxController {
  TextEditingController goalsController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  ChipProperties? originalChipProperties;
  var chips = <ChipProperties>[
    ChipProperties(
        text: '#All', fontColor: Colors.white, backgroundColor: Colors.grey),
    ChipProperties(
        text: '#Work', fontColor: Colors.white, backgroundColor: Colors.grey),
    ChipProperties(
        text: '#Home', fontColor: Colors.white, backgroundColor: Colors.grey),
    ChipProperties(
        text: '#Personal',
        fontColor: Colors.white,
        backgroundColor: Colors.grey),
    ChipProperties(
        text: '#Goals', fontColor: Colors.white, backgroundColor: Colors.grey),
  ].obs;

  // Track the selected chip index
  var selectedChipIndex = 0.obs;
  var originalFontColor = Colors.white.obs;
  MaterialColor originalBackgroundColor = Colors.blue;

  @override
  void onInit() {
    super.onInit();
    originalFontColor.value = chips[0].fontColor!;

    originalBackgroundColor = chips[0].backgroundColor as MaterialColor;

    chips[0].fontColor = Colors.black;
    chips[0].backgroundColor = Colors.blue;
  }

  void updateChipColor(
      int index, Color newFontColor, Color newBackgroundColor) {
    if (index >= 0 && index < chips.length) {
      if (selectedChipIndex.value == index) {
        // Revert to original properties
        chips[index].fontColor = originalFontColor.value;
        chips[index].backgroundColor = originalBackgroundColor;
        selectedChipIndex.value = -1; // Deselect the chip
      } else {
        if (selectedChipIndex.value != -1) {
          // Revert previously selected chip to original properties
          chips[selectedChipIndex.value].fontColor = originalFontColor.value;
          chips[selectedChipIndex.value].backgroundColor =
              originalBackgroundColor;
        }
        // Store the original properties of the new chip
        originalFontColor.value = chips[index].fontColor!;
        originalBackgroundColor = chips[index].backgroundColor as MaterialColor;

        // Update to new properties
        chips[index].fontColor = newFontColor;
        chips[index].backgroundColor = newBackgroundColor;
        selectedChipIndex.value = index; // Select the new chip
      }
      chips.refresh(); // Notify listeners
    }
  }

  String hintText() {
 
    switch (selectedChipIndex.value) {
      case 0:
        return 'Enter your goals';
      case 1:
        return 'Enter your work task';
      case 2:
        return 'Enter your home task';
      case 3:
        return 'Enter your personal task';
      case 4:
        return 'Enter your goals';
      default:
        return 'Enter your task';
    }
  }
}

// Method to update the chip properties
// void updateChip(
//     int index, Color newFontColor, MaterialColor newBackgroundColor) {
//   // change color of the chip based on the index

//   fontColor.value = newFontColor;
//   backgroundColor.value = newBackgroundColor;
// }

//add task function
// void addTask() {
//   //get the task title
//   String taskTitle = goalsController.text;

//   //get the task description
//   String taskDescription = descriptionController.text;

//   //check if the task title is empty
//   if (taskTitle.isEmpty) {
//     Get.snackbar("Error", "Task title cannot be empty");
//     return;
//   }

//   //check if the task description is empty
//   // if (taskDescription.isEmpty) {
//   //   Get.snackbar("Error", "Task description cannot be empty");
//   //   return;
//   // }

//   //add the task to the database
//   addTaskToDatabase(taskTitle, taskDescription);

//   //clear the text fields
//   goalsController.clear();
//   descriptionController.clear();

//   //show a snackbar
//   Get.snackbar("Success", "Task added successfully");
// }

// //add task to database function
// void addTaskToDatabase(String taskTitle, String taskDescription) {
//   //get the current user
//   User? user = FirebaseAuth.instance.currentUser;

//   //get the current user id
//   String? userId = user?.uid;
//   //get the current date
//   String date = DateTime.now().toString();

//   //add the task to the database
//   FirebaseFirestore.instance.collection("tasks").doc(userId).set({
//     "taskTitle": taskTitle,
//     "taskDescription": taskDescription,
//     "date": date,
//   });
// }

class ChipProperties {
  Color? fontColor;
  Color? backgroundColor;
  String? text;

  ChipProperties({this.fontColor, this.backgroundColor, required this.text});
}
