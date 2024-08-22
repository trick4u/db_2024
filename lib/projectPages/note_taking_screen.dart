import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:tushar_db/projectController/note_taking_controller.dart';

import '../models/note_model.dart';
import '../services/app_theme.dart';
import '../widgets/note_listView.dart';

class NoteTakingScreen extends GetWidget<NoteTakingController> {
  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();
    return Scaffold(
      appBar: AppBar(
        title: Text('your notes'),
      ),
      body: NoteListView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showNoteBottomSheet(context, null);
        },
        backgroundColor: appTheme.colorScheme.primary,
      ),
    );
  }


  void _showNoteBottomSheet(BuildContext context, Note? note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: NoteBottomSheet(note: note),
      ),
    );
  }
}

class NoteBottomSheet extends GetView<NoteTakingController> {
  final Note? note;
  final AppTheme appTheme = Get.find<AppTheme>();

  NoteBottomSheet({this.note});

  @override
  Widget build(BuildContext context) {
    if (note != null) {
      controller.initializeForEditing(note!);
    } else {
      controller.clearFields();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Card(
        elevation: 8,
        color: appTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(note == null ? 'Add Note' : 'Edit Note',
                      style: appTheme.titleLarge),
                  Spacer(),
                  _buildDatePicker(context),
                  IconButton(
                    icon: Icon(Icons.close, color: appTheme.textColor),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 10),
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
              SizedBox(height: 10),
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
                                  hintStyle: appTheme.bodyMedium.copyWith(
                                      color: appTheme.secondaryTextColor),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SlideInRight(
                    child: Row(
                      children: [
                        Obx(() => controller.subTasks.length <
                                NoteTakingController.maxSubTasks
                            ? _buildSubTaskToggleButton()
                            : SizedBox()),
                        SizedBox(width: 16),
                        _buildSaveIconButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showOmniDateTimePicker(
          context: context,
          initialDate: controller.selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
          is24HourMode: true,
          isShowSeconds: false,
          minutesInterval: 1,
          secondsInterval: 1,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          constraints: const BoxConstraints(
            maxWidth: 200,
            maxHeight: 400,
          ),
          transitionBuilder: (context, anim1, anim2, child) {
            return FadeTransition(
              opacity: anim1.drive(
                Tween(
                  begin: 0,
                  end: 1,
                ),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
          barrierDismissible: true,
          selectableDayPredicate: (dateTime) {
            // Allow selecting any date
            return true;
          },
        );

        if (pickedDate != null && pickedDate != controller.selectedDate) {
          controller.updateSelectedDate(pickedDate);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: appTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  '${controller.selectedDate.day}/${controller.selectedDate.month}/${controller.selectedDate.year}',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            )),
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
              onTap: controller.canSave
                  ? () {
                      if (note == null) {
                        controller.saveNote();
                      } else {
                           Note updatedNote = note!.copyWith(
                          title: controller.titleController.text.trim(),
                          subTasks: controller.subTasks
                              .map((controller) => controller.text.trim())
                              .toList(),
                          date: controller.selectedDate,
                          updatedAt: DateTime.now(),
                        );
                       controller.updateNote(note!.id ?? "", updatedNote);
                      }
                    }
                  : null,
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
