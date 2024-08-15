import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/projectController/note_taking_controller.dart';

class NoteTakingScreen extends GetWidget<NoteTakingController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
