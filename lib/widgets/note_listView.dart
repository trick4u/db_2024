import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../models/note_model.dart';
import '../projectController/note_taking_controller.dart';
import '../projectPages/note_taking_screen.dart';
import '../services/app_theme.dart';

class NoteListView extends GetWidget<NoteTakingController> {
  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<AppTheme>();
    return Obx(() => ListView.builder(
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            Note note = controller.notes[index];
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
              child: Obx(() => Card(
                    elevation: 0,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(note.title, style: appTheme.bodyMedium),
                        trailing: note.subTasks.isNotEmpty
                            ? Icon(Icons.expand_more)
                            : SizedBox.shrink(),
                        children: note.subTasks.isNotEmpty
                            ? [
                                ...note.subTasks.asMap().entries.map(
                                  (entry) {
                                    int subTaskIndex = entry.key;
                                    String subTask = entry.value;
                                    return ListTile(
                                      leading:
                                          Icon(Icons.subdirectory_arrow_right),
                                      title: Text(subTask,
                                          style: appTheme.bodyMedium),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
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
                  )),
            );
          },
        ));
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
