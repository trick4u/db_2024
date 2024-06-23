

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTaskController extends GetxController{
 
 var isTopMoved = false.obs;

  void moveTopRight() {
    isTopMoved.value = !isTopMoved.value;
  }

  void moveBottomRight() {
    isTopMoved.value = !isTopMoved.value;
  }

}