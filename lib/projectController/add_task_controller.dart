

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTaskController extends GetxController{

  // TextEditingController for the task title
  TextEditingController goalsController = TextEditingController();

  // TextEditingController for the task description
  TextEditingController descriptionController = TextEditingController();

  
  //add task function
  void addTask() {
    //get the task title
    String taskTitle = goalsController.text;

    //get the task description
    String taskDescription = descriptionController.text;

    //check if the task title is empty
    if (taskTitle.isEmpty) {
      Get.snackbar("Error", "Task title cannot be empty");
      return;
    }

    //check if the task description is empty
    if (taskDescription.isEmpty) {
      Get.snackbar("Error", "Task description cannot be empty");
      return;
    }

    //add the task to the database
    //addTaskToDatabase(taskTitle, taskDescription);

    //clear the text fields
    goalsController.clear();
    descriptionController.clear();

    //show a snackbar
    Get.snackbar("Success", "Task added successfully");
  }


 
 
 






}