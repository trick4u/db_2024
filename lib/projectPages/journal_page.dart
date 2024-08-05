import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../projectController/journal_controller.dart';
import '../services/app_theme.dart';

class JournalPage extends GetWidget<JournalController> {
  final JournalEntry? entry;

  JournalPage({this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              FontAwesomeIcons.plus,
              size: ScaleUtil.fontSize(15),
            ),
          ),
        ],
      ),
      body: Obx(() => controller.journalEntries.length == 0
          ? JournalEntryView()
          : ListView.builder(
              itemCount: controller.journalEntries.length,
              itemBuilder: (context, index) {
                final entry = controller.journalEntries[index];
                return Card(
                  child: ListTile(
                    title: Text(entry.title),
                    subtitle: Text(
                      DateFormat('MMMM d, yyyy').format(entry.date),
                    ),
                    onTap: () => Get.to(
                      () => JournalEntryView(entry: entry),
                    ),
                  ),
                );
              },
            )),
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

    return Material(
      child: Padding(
        padding: ScaleUtil.symmetric(horizontal: 20, vertical: 10),
        child: SafeArea(
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
                  child: Text(DateFormat('MMMM d, yyyy').format(currentDate),
                      style: appTheme.bodyMedium),
                ),
              ),
              SizedBox(
                height: ScaleUtil.height(20),
              ),
              Container(
                decoration: BoxDecoration(
                  color: appTheme.textFieldFillColor,
                  borderRadius:
                      BorderRadius.circular(10), // Apply to all corners
                ),
                child: TextField(
                  controller: titleController,
                  style: appTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: "Please write on..",
                    filled: true,
                    fillColor: Colors
                        .transparent, // Make this transparent as the Container handles the background
                    labelStyle: appTheme.bodyMedium.copyWith(
                      color: appTheme.secondaryTextColor,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              SizedBox(
                height: ScaleUtil.height(16),
              ),
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: appTheme.textFieldFillColor,
                  borderRadius:
                      BorderRadius.circular(10), // Apply to all corners
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      10), // Match the Container's border radius
                  child: TextField(
                    controller: contentController,
                    style: appTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: "Please write on..",
                      filled: true,
                      fillColor: Colors
                          .transparent, // Make this transparent as the Container handles the background
                      labelStyle: appTheme.bodyMedium.copyWith(
                        color: appTheme.secondaryTextColor,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null, // Allow unlimited lines
                    expands:
                        true, // Make the TextField expand to fill the available space
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
