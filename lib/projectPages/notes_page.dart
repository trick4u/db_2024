import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../projectController/notes_page_controller.dart';
import 'add_note_page.dart';

class NotesPage extends StatelessWidget {
  final NotesPageController controller = Get.put(NotesPageController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'personal notes',
                  style: TextStyle(
                    fontFamily: 'Euclid',
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                //add note button
                Spacer(),
                IconButton(
                  icon: Icon(FontAwesomeIcons.plus),
                  onPressed: () {
                    //add note
                    Get.to(() => AddNotePage());
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                FilterChip(
                  label: Text('filters'),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey),
                  ),
                  selected: controller.selectedFilter == 'filters',
                  onSelected: (isSelected) {
                    controller.setFilter('filters');
                  },
                ),
                FilterChip(
                  label: Text('important'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey),
                  ),
                  backgroundColor: Colors.white,
                  selected: controller.selectedFilter == 'important',
                  onSelected: (isSelected) {
                    controller.setFilter('important');
                  },
                ),
                FilterChip(
                  label: Text('to-do'),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey),
                  ),
                  selected: controller.selectedFilter == 'to-do',
                  onSelected: (isSelected) {
                    controller.setFilter('to-do');
                  },
                ),
                FilterChip(
                  label: Text('favorite'),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey),
                  ),
                  selected: controller.selectedFilter == 'favorite',
                  onSelected: (isSelected) {
                    controller.setFilter('favorite');
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                return ListView(
                  children: controller.filteredNotes.map((note) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(note.content),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class NotesController extends GetxController {}
