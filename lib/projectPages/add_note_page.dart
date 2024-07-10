import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNotePage extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: titleController,
              
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
              

                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 10),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: statusController,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String title = titleController.text;
                  String content = contentController.text;
                  String date = dateController.text;
                  String location = locationController.text;
                  String status = statusController.text;

                  if (title.isNotEmpty &&
                      content.isNotEmpty &&
                      date.isNotEmpty &&
                      location.isNotEmpty &&
                      status.isNotEmpty) {
                    await FirebaseFirestore.instance.collection('notes').add({
                      'title': title,
                      'content': content,
                      'date': date,
                      'status': status,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    Get.snackbar(
                      'Success',
                      'Note added successfully',
                      snackPosition: SnackPosition.BOTTOM,
                    );

                    Navigator.pop(context);
                  } else {
                    Get.snackbar(
                      'Error',
                      'Please fill in all fields',
                      snackPosition: SnackPosition.BOTTOM,
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
