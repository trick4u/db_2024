

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/task_model.dart';

class EatTheFrogController extends GetxController {

    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var tasks = <Task>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  void fetchTasks() {
    _firestore.collection('tasks').orderBy('priority').snapshots().listen((snapshot) {
      tasks.value = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }

  void addTask(Task task) {
    _firestore.collection('tasks').add(task.toFirestore());
  }

  void updateTask(Task task) {
    _firestore.collection('tasks').doc(task.id).update(task.toFirestore());
  }

  void deleteTask(String id) {
    _firestore.collection('tasks').doc(id).delete();
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final Task item = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, item);
    // Update priority in Firestore
    for (int i = 0; i < tasks.length; i++) {
      tasks[i].priority = i;
      updateTask(tasks[i]);
    }
  }

}
