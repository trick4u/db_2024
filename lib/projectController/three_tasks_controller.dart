import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThreeTasksController extends GetxController {
  RxString timeOfDay = ''.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  

  //textfields
  RxString task1 = ''.obs;
  RxString task2 = ''.obs;
  RxString task3 = ''.obs;

  //textediting controllers
  TextEditingController task1Controller = TextEditingController();
  TextEditingController task2Controller = TextEditingController();
  TextEditingController task3Controller = TextEditingController();

  @override
  void onReady() {
    timeOfDay.value = Get.arguments['timeOfDay'];
    super.onReady();
  }

  //save taks to firestore
  void saveTasks(String taskTime) {
    // only save if at least one task is entered
    if (task1.value.isEmpty && task2.value.isEmpty && task3.value.isEmpty) {
      Get.snackbar('Error', 'Please enter at least one task');
      return;
    } else {
      _firestore.collection('users').doc(_auth.currentUser?.uid).collection(taskTime).add({
        'task1': task1.value,
        'task2': task2.value,
        'task3': task3.value,
        'timeOfDay': timeOfDay.value,
        'createdAt': FieldValue.serverTimestamp(),
      
      });
      
      Get.snackbar('Success', 'Tasks saved successfully');
    
    }
  }
}
