import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../projectController/journal_controller.dart';
import '../services/app_theme.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class JournalPage extends GetWidget<JournalController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Journal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: () => Get.to(() => JournalEntryView()),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Obx(
          () => controller.journalEntries.isEmpty
              ? Center(child: Text('No entries yet. Add one!'))
              : MasonryGridView.count(
                  crossAxisCount: 3,
                  itemCount: controller.journalEntries.length,
                  itemBuilder: (BuildContext context, int index) {
                    final entry = controller.journalEntries[index];
                    return GestureDetector(
                      onTap: () =>
                          Get.to(() => JournalDetailView(entry: entry)),
                      child: Card(
                        color: index % 2 == 0
                            ? Colors.grey[800]
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: index % 2 == 0
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    entry.content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: index % 2 == 0
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    DateFormat('MMM d, yyyy')
                                        .format(entry.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: index % 2 == 0
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: index % 2 == 0
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                onPressed: () => _showDeleteConfirmationDialog(
                                    context, entry),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, JournalEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Entry'),
          content: Text('Are you sure you want to delete this journal entry?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                controller.removeEntry(entry.id);
                Navigator.of(context).pop();
                Get.snackbar('Success', 'Journal entry deleted successfully!');
              },
            ),
          ],
        );
      },
    );
  }
}

class JournalDetailView extends StatelessWidget {
  final JournalEntry entry;
  final appTheme = Get.find<AppTheme>();

  JournalDetailView({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal Entry'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Get.to(() => JournalEntryView(entry: entry)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              DateFormat('MMMM d, yyyy').format(entry.date),
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              entry.content,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class JournalEntryView extends GetWidget<JournalController> {
  final JournalEntry? entry;

  JournalEntryView({this.entry});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: entry?.title ?? '');
    final contentController = TextEditingController(text: entry?.content ?? '');
    final currentDate = entry?.date ?? DateTime.now();
    final appTheme = Get.find<AppTheme>();

    return Scaffold(
      appBar: AppBar(
        title: Text(entry == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              final newEntry = JournalEntry(
                id: entry?.id ?? '',
                title: titleController.text,
                content: contentController.text,
                date: currentDate,
              );

              try {
                if (entry == null) {
                  await controller.addEntry(newEntry);
                } else {
                  await controller.updateEntry(newEntry);
                }
                Get.back();
                Get.snackbar('Success', 'Journal entry saved successfully!');
              } catch (e) {
                Get.snackbar('Error', 'Failed to save journal entry: $e');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: ScaleUtil.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              PressableDough(
                onReleased: (d) {
                  appTheme.toggleTheme();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    DateFormat('MMMM d, yyyy').format(currentDate),
                    style: appTheme.bodyMedium.copyWith(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: ScaleUtil.height(20)),
              Container(
                decoration: BoxDecoration(
                  color: appTheme.textFieldFillColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: titleController,
                  style: appTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: "What should be its title..",
                    filled: true,
                    fillColor: Colors.transparent,
                    labelStyle: appTheme.bodyMedium.copyWith(
                      color: appTheme.secondaryTextColor,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              SizedBox(height: ScaleUtil.height(16)),
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: appTheme.textFieldFillColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TextField(
                    controller: contentController,
                    style: appTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: "Please write on..",
                      filled: true,
                      fillColor: Colors.transparent,
                      labelStyle: appTheme.bodyMedium.copyWith(
                        color: appTheme.secondaryTextColor,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                    expands: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
