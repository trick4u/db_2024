import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../projectController/notes_page_controller.dart';
import 'add_note_page.dart';
import 'notes_details_page.dart';

class NotesPage extends StatelessWidget {
  final NotesPageController controller = Get.put(NotesPageController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              child: Obx(
                () => GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 4,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                    pattern: [
                      QuiltedGridTile(2, 2),
                      QuiltedGridTile(1, 1),
                      QuiltedGridTile(1, 1),
                    ],
                  ),
                  itemCount: controller.filteredNotes.length,
                  itemBuilder: (context, index) {
                    var content = controller.filteredNotes[index].content;
                    // only show the first 50 characters

                    return InkWell(
                      onTap: () {
                        Get.to(() => NoteDetailPage(),
                            arguments: controller.filteredNotes[index]);
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: index % 3 == 0
                              ? Colors.black54
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                          //shadow
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0, 2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                controller.filteredNotes[index].title,
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: index % 3 == 0
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            // only show content if the container is big enough

                            Expanded(
                              child: Text(
                                content,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: index % 3 == 0
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotesController extends GetxController {}
