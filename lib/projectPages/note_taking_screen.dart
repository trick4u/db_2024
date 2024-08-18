import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tushar_db/projectController/note_taking_controller.dart';

import '../services/app_theme.dart';

class NoteTakingScreen extends GetWidget<NoteTakingController> {
  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showNoteBottomSheet(context);
        },
        backgroundColor: appTheme.colorScheme.primary,
      ),
    );
  }

  void _showNoteBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: NoteBottomSheet(),
        ),
      ),
    );
  }
}

class NoteBottomSheet extends GetView<NoteTakingController> {
  final AppTheme appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Note', style: appTheme.titleLarge),
              IconButton(
                icon: Icon(Icons.close, color: appTheme.textColor),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: TextField(
              controller: controller.titleController,
              style: appTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Note Title',
                filled: true,
                fillColor: appTheme.textFieldFillColor,
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
          SizedBox(height: 16),
          Obx(() => Column(
                children: controller.subTasks.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController subTaskController = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Radio<bool>(
                          value: false,
                          groupValue: null,
                          onChanged: (value) {},
                          activeColor: appTheme.colorScheme.primary,
                        ),
                        Expanded(
                          child: TextField(
                            controller: subTaskController,
                            style: appTheme.bodyMedium,
                            maxLength: 70,
                            decoration: InputDecoration(
                              hintText: 'Input the sub-task',
                              hintStyle: appTheme.bodyMedium
                                  .copyWith(color: appTheme.secondaryTextColor),
                              border: InputBorder.none,
                              counterText: '',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.close,
                                    size: 18,
                                    color: appTheme.secondaryTextColor),
                                onPressed: () =>
                                    controller.removeSubTask(index),
                              ),
                            ),
                            onChanged: (value) =>
                                controller.updateSubTask(index, value),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildSubTaskToggleButton(),
              SizedBox(width: 16),
              _buildSaveIconButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubTaskToggleButton() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: controller.canAddSubTask
                ? appTheme.colorScheme.primary
                : appTheme.colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: controller.canAddSubTask ? controller.addSubTask : null,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: FaIcon(
                  FontAwesomeIcons.listUl,
                  color: controller.canAddSubTask ? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildSaveIconButton() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color:
                controller.canSave ? appTheme.colorScheme.primary : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: controller.canSave ? controller.saveNote : null,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  FontAwesomeIcons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ));
  }
}
