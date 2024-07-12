import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/projectController/eat_the_frog_controller.dart';

import '../models/task_model.dart';

class EatTheFrog extends GetWidget<EatTheFrogController> {
  final TextEditingController titleController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eat the Frog'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final newTask = Task(
                      id: '',
                      title: titleController.text,
                      priority: controller.tasks.length,
                      isFrog: controller.tasks.isEmpty,
                    );
                    controller.addTask(newTask);
                    titleController.clear();
                  },
                ),
              ),
            ),
          ),
          Obx(() {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: ReorderableListView(
                onReorder: controller.reorderTasks,
                children: [
                  for (final task in controller.tasks)
                    ListTile(
                      key: ValueKey(task.id),
                      title: Text(task.title),
                      leading: IconButton(
                          onPressed: () {
                            task.isFrog = !task.isFrog;
                            controller.updateTask(task);
                          },
                          icon: Icon(Icons.edit)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => controller.deleteTask(task.id),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
