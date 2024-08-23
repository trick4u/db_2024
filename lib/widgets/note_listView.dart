import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../models/note_model.dart';
import '../projectController/note_taking_controller.dart';
import '../projectPages/note_taking_screen.dart';
import '../services/app_theme.dart';

class NoteListView extends GetWidget<NoteTakingController> {
  Color _getTileColor(int index, int totalItems) {
    if (totalItems == 1) return Colors.white;

    double t = index / (totalItems - 1);
    return Color.lerp(Colors.white, Colors.deepPurpleAccent, t)!;
  }

  TextStyle _getTextStyle(
      Color textColor, bool isCompleted, AppTheme appTheme) {
    return appTheme.bodyMedium.copyWith(
      color: textColor,
      decoration:
          isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
      decorationColor:
          textColor.computeLuminance() > 0.5 ? Colors.white : Colors.black,
      decorationThickness: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();
    return Obx(() {
      if (controller.isLoading.value && controller.notes.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      return FadeIn(
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo is ScrollEndNotification &&
                scrollInfo.metrics.extentAfter == 0 &&
                !controller.isLoadingMore.value) {
              controller.fetchNotes(loadMore: true);
            }
            return false;
          },
          child: ListView.builder(
            itemCount: controller.notes.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.notes.length) {
                return Center(child: CircularProgressIndicator());
              }

              Note note = controller.notes[index];
              Color tileColor = _getTileColor(index, controller.notes.length);
              Color textColor = tileColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white;
              TextStyle textStyle =
                  _getTextStyle(textColor, note.isCompleted, appTheme);

              return Slidable(
                key: ValueKey(note.id),
                endActionPane: ActionPane(
                  motion: const BehindMotion(),
                  extentRatio: 0.5,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit,
                      label: 'Edit',
                      color: Colors.blue,
                      onTap: () => _showNoteBottomSheet(context, note),
                    ),
                    _buildActionButton(
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.red,
                      onTap: () => controller.deleteNote(note.id ?? ""),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 1,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: tileColor,
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: note.isCompleted,
                          onChanged: (_) =>
                              controller.toggleNoteCompletion(note.id!),
                          activeColor: Colors.green,
                          checkColor: textColor,
                          side: BorderSide(color: textColor),
                        ),
                      ),
                      title: Text(
                        note.title,
                        style: textStyle,
                      ),
                      trailing: SizedBox(
                        width: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('MMM d, yyyy').format(note.date),
                              style: textStyle.copyWith(
                                color: textColor.withOpacity(0.7),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(width: 8),
                            SizedBox(
                              width: 24,
                              child: note.subTasks.isNotEmpty
                                  ? Icon(Icons.expand_more, color: textColor)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      children: note.subTasks.isNotEmpty
                          ? [
                              ...note.subTasks.asMap().entries.map(
                                (entry) {
                                  int subTaskIndex = entry.key;
                                  String subTask = entry.value;
                                  return ListTile(
                                    tileColor: tileColor,
                                    leading: Icon(
                                      Icons.subdirectory_arrow_right,
                                      color: textColor,
                                    ),
                                    title: Text(
                                      subTask,
                                      style: textStyle,
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.close,
                                          color: textColor.withOpacity(0.7)),
                                      onPressed: () async {
                                        await controller.deleteSubTask(
                                            note.id ?? "", subTaskIndex);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomSlidableAction(
      onPressed: (_) => onTap(),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
