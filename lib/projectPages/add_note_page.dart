import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/toast_util.dart';

class AddNotePage extends StatelessWidget {
  final AddNoteController controller = Get.put(AddNoteController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Note',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  controller.title.value = value;
                },
              ),
              SizedBox(height: 10),
              Obx(() {
                return Column(
                  children: List.generate(controller.pointers.length, (index) {
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Pointer ${index + 1}',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                controller.updatePointer(index, value);
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: () {
                            controller.removePointer(index);
                          },
                        ),
                      ],
                    );
                  }),
                );
              }),
              TextButton(
                onPressed: controller.addPointer,
                child: Text('Add Pointer'),
              ),
              Obx(() {
                return Column(
                  children: List.generate(controller.subPlots.length, (index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Sub Plot Heading ${index + 1}',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    controller.updateSubPlotHeading(
                                        index, value);
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle),
                              onPressed: () {
                                controller.removeSubPlot(index);
                              },
                            ),
                          ],
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Sub Plot Content ${index + 1}',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            controller.updateSubPlotContent(index, value);
                          },
                        ),
                      ],
                    );
                  }),
                );
              }),
              TextButton(
                onPressed: controller.addSubPlot,
                child: Text('Add Sub Plot'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String title = controller.title.value;
                  List<String> pointers = controller.pointers;
                  List<Map<String, String>> subPlots = controller.subPlots;

                  if (title.isNotEmpty) {
                    await FirebaseFirestore.instance.collection('notes').add({
                      'title': title,
                      'date': controller.date.value,
                      'pointers': pointers,
                      'subPlots': subPlots,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    ToastUtil.showToast(
                      'Success',
                      'Note added successfully',
                     
                    );

                    Navigator.pop(context);
                  } else {
                    ToastUtil.showToast(
                      'Error',
                      'Please fill in the title',
                     
                    );
                  }
                },
                child: Text('Add Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddNoteController extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  var title = ''.obs;
  var date = DateTime.now().obs;
  var pointers = <String>[].obs;
  var subPlots = <Map<String, String>>[].obs;

  void addPointer() {
    pointers.add('');
  }

  void removePointer(int index) {
    pointers.removeAt(index);
  }

  void addSubPlot() {
    subPlots.add({'heading': '', 'content': ''});
  }

  void removeSubPlot(int index) {
    subPlots.removeAt(index);
  }

  void updatePointer(int index, String value) {
    pointers[index] = value;
  }

  void updateSubPlotHeading(int index, String value) {
    subPlots[index]['heading'] = value;
  }

  void updateSubPlotContent(int index, String value) {
    subPlots[index]['content'] = value;
  }
}
