import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:tushar_db/projectController/note_taking_controller.dart';

import '../models/note_model.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';
import '../widgets/note_listView.dart';

class NoteTakingScreen extends GetWidget<NoteTakingController> {
  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();
    ScaleUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('your notes',
            style: TextStyle(fontSize: ScaleUtil.fontSize(20))),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever, size: ScaleUtil.iconSize(24)),
            onPressed: () => _showDeleteAllConfirmation(context),
          ),
        ],
      ),
      body: NoteListView(),
      floatingActionButton: Obx(() {
        return controller.canAddMoreNotes
            ? FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  _showNoteBottomSheet(context);
                },
                child: Icon(
                  Icons.add,
                  color: Colors.deepPurpleAccent,
                  size: ScaleUtil.iconSize(24),
                ),
              )
            : SizedBox.shrink();
      }),
    );
  }

  void _showDeleteAllConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete All Notes',
              style: TextStyle(fontSize: ScaleUtil.fontSize(18))),
          content: Text(
            'Are you sure you want to delete all notes? This action cannot be undone.',
            style: TextStyle(fontSize: ScaleUtil.fontSize(16)),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete All',
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16))),
              onPressed: () {
                controller.deleteAllNotes();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showNoteBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: NoteBottomSheet(),
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
      padding: ScaleUtil.only(left: 10, right: 10, bottom: 10),
      child: Card(
        elevation: ScaleUtil.scale(8),
        color: appTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: ScaleUtil.circular(20),
        ),
        child: Container(
          padding: ScaleUtil.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    note == null ? 'Add Note' : 'Edit Note',
                    style: appTheme.titleLarge.copyWith(
                      fontSize: ScaleUtil.fontSize(15),
                    ),
                  ),
                  Spacer(),
                  _buildDatePicker(context),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: appTheme.textColor,
                        size: ScaleUtil.iconSize(15)),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              ScaleUtil.sizedBox(height: 10),
              ClipRRect(
                borderRadius: ScaleUtil.circular(10),
                child: TextField(
                  controller: controller.titleController,
                  style: appTheme.bodyMedium
                      .copyWith(fontSize: ScaleUtil.fontSize(16)),
                  decoration: InputDecoration(
                    labelText: 'Note Title',
                    filled: true,
                    fillColor: appTheme.textFieldFillColor,
                    labelStyle: appTheme.bodyMedium.copyWith(
                      color: appTheme.secondaryTextColor,
                      fontSize: ScaleUtil.fontSize(16),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding:
                        ScaleUtil.symmetric(horizontal: 16, vertical: 6),
                  ),
                ),
              ),
              ScaleUtil.sizedBox(height: 10),
              Obx(() => Column(
                    children: controller.subTasks.asMap().entries.map((entry) {
                      int index = entry.key;
                      TextEditingController subTaskController = entry.value;
                      return Padding(
                        padding: ScaleUtil.only(bottom: 8.0),
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
                                style: appTheme.bodyMedium
                                    .copyWith(fontSize: ScaleUtil.fontSize(16)),
                                maxLength: 70,
                                decoration: InputDecoration(
                                  hintText: 'Input the sub-task',
                                  hintStyle: appTheme.bodyMedium.copyWith(
                                    color: appTheme.secondaryTextColor,
                                    fontSize: ScaleUtil.fontSize(16),
                                  ),
                                  border: InputBorder.none,
                                  counterText: '',
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.close,
                                        size: ScaleUtil.iconSize(18),
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
                        ScaleUtil.sizedBox(width: 16),
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
          borderRadius: ScaleUtil.circular(16),
          constraints: BoxConstraints(
            maxWidth: ScaleUtil.width(200),
            maxHeight: ScaleUtil.height(400),
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
            return true;
          },
        );

        if (pickedDate != null && pickedDate != controller.selectedDate) {
          controller.updateSelectedDate(pickedDate);
        }
      },
      child: Container(
        padding: ScaleUtil.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: appTheme.colorScheme.primary,
          borderRadius: ScaleUtil.circular(8),
        ),
        child: Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today,
                    color: Colors.white, size: ScaleUtil.iconSize(16)),
                ScaleUtil.sizedBox(width: 8),
                Text(
                  '${controller.selectedDate.day}/${controller.selectedDate.month}/${controller.selectedDate.year}',
                  style: TextStyle(
                      color: Colors.white, fontSize: ScaleUtil.fontSize(14)),
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
              borderRadius: ScaleUtil.circular(20),
              onTap: controller.canAddSubTask ? controller.addSubTask : null,
              child: Padding(
                padding: ScaleUtil.all(10),
                child: FaIcon(
                  FontAwesomeIcons.listUl,
                  color: controller.canAddSubTask ? Colors.white : Colors.black,
                  size: ScaleUtil.iconSize(15),
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
              borderRadius: ScaleUtil.circular(20),
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
                padding: ScaleUtil.all(10),
                child: Icon(
                  FontAwesomeIcons.check,
                  color: Colors.white,
                  size: ScaleUtil.iconSize(15),
                ),
              ),
            ),
          ),
        ));
  }
}
