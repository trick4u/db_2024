import 'package:flutter/material.dart';
import 'package:get/get.dart';



class NoteTakingController extends GetxController {
  final titleController = TextEditingController();
  final subTasks = <TextEditingController>[].obs;
  final _canAddSubTask = false.obs;
  final _canSave = false.obs;

  bool get canAddSubTask => _canAddSubTask.value;
  bool get canSave => _canSave.value;

  @override
  void onInit() {
    super.onInit();
    ever(subTasks, (_) => _updateState());
    titleController.addListener(_updateState);
  }

  void _updateState() {
    if (subTasks.isEmpty) {
      _canAddSubTask.value = titleController.text.trim().isNotEmpty;
    } else {
      _canAddSubTask.value = subTasks.last.text.trim().isNotEmpty;
    }
    _canSave.value = titleController.text.trim().isNotEmpty;
  }

  void addSubTask() {
    if (canAddSubTask) {
      subTasks.add(TextEditingController());
      _updateState();
    }
  }

  void updateSubTask(int index, String value) {
    if (index >= 0 && index < subTasks.length) {
      subTasks[index].text = value;
      _updateState();
    }
  }

  void removeSubTask(int index) {
    if (index >= 0 && index < subTasks.length) {
      subTasks[index].dispose();
      subTasks.removeAt(index);
      _updateState();
    }
  }

  void saveNote() {
    if (canSave) {
      // Implement your save logic here
      print('Saving note:');
      print('Title: ${titleController.text.trim()}');
      for (var i = 0; i < subTasks.length; i++) {
        print('Sub-task $i: ${subTasks[i].text.trim()}');
      }
      Get.back(); // Close the bottom sheet
      clearFields();
    }
  }

  void clearFields() {
    titleController.clear();
    for (var controller in subTasks) {
      controller.dispose();
    }
    subTasks.clear();
    _updateState();
  }

  @override
  void onClose() {
    titleController.dispose();
    for (var controller in subTasks) {
      controller.dispose();
    }
    super.onClose();
  }
}