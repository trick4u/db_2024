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
import '../widgets/note_bottom_sheet.dart';
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

