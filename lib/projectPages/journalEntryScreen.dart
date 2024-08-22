import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../projectController/journal_controller.dart';
import '../services/app_theme.dart';

class JournalEntryScreen extends GetWidget<JournalController> {
  final JournalEntry? entry;
  final AppTheme appTheme = Get.find<AppTheme>();

  JournalEntryScreen({Key? key, this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is initialized
    final JournalController controller = Get.find<JournalController>();
    controller.initEntryEdit(entry);

    return Scaffold(
      appBar: AppBar(
        title: Text(entry == null ? 'New Journal Entry' : 'Edit Journal Entry'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: controller.saveEntry,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller.titleController,
              style: appTheme.titleLarge,
              decoration: InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller.contentController,
                style: appTheme.bodyMedium,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Write your thoughts...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
