import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
        appTheme.updateStatusBarColor();
    
    return Obx(() => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: appTheme.isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
       
          elevation: 0,
          title: Text('your notes',
              style: TextStyle(fontSize: ScaleUtil.fontSize(20))),
          actions: [
            IconButton(
              icon: Icon(Icons.delete_forever, size: ScaleUtil.iconSize(24)),
              onPressed: () => _showDeleteAllConfirmation(context),
            ),
          ],
        ),
        body: SafeArea(
          child: NoteListView(),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    ));
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      return controller.canAddMoreNotes
          ? FloatingActionButton(
              backgroundColor: appTheme.isDarkMode ? Colors.white : Colors.deepPurpleAccent,
              onPressed: () {
                _showNoteBottomSheet(Get.context!);
              },
              child: Icon(
                Icons.add,
                color: appTheme.isDarkMode ? Colors.deepPurpleAccent : Colors.white,
                size: ScaleUtil.iconSize(20),
              ),
            )
          : SizedBox.shrink();
    });
  }

  void _showDeleteAllConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appTheme.isDarkMode ? Colors.grey[900] : Colors.white,
          title: Text('Delete All Notes',
              style: TextStyle(fontSize: ScaleUtil.fontSize(18), color: appTheme.isDarkMode ? Colors.white : Colors.black)),
          content: Text(
            'Are you sure you want to delete all notes? This action cannot be undone.',
            style: TextStyle(fontSize: ScaleUtil.fontSize(16), color: appTheme.isDarkMode ? Colors.white70 : Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16), color: appTheme.isDarkMode ? Colors.white70 : Colors.black87)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete All',
                  style: TextStyle(fontSize: ScaleUtil.fontSize(16), color: Colors.red)),
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