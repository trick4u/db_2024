

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEverythingController extends GetxController {

   TextEditingController goalsController = TextEditingController();
   var fireStoreInstance = FirebaseFirestore.instance;
    var text = "".obs;

  

  

  @override
  void onInit() {
    goalsController = TextEditingController();
    
    super.onInit();
  }

  @override
  void onClose() {
    goalsController.dispose();
    super.onClose();
  }


  void setText(String value) {
    text.value = value;
  }
    //add goals to firestore
  Future<void> addGoals(String goal) async {
    await fireStoreInstance
        .collection("goals")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("userGoals")
        .add({
      "goal": goal,
      "createdAt": FieldValue.serverTimestamp(),
    }).then((_) {
      Get.back();
    });
  }

}