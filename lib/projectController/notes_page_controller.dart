import 'package:get/get.dart';

class NotesPageController extends GetxController {
  var selectedFilter = ''.obs;
  var notes = <Note>[
    Note(
      title: 'how I found a new dream',
      content: 'Today my wish has come true – to devote the whole d...',
    ),
    Note(
      title: 'my plan for the future me',
      content: 'Imagine the perfect life, the perfect family, dream house...',
    ),
    Note(
      title: 'how I found a new dream',
      content: 'Today my wish has come true – to devote the whole d...Imagine the perfect life, the perfect family, dream house..',
    ),
    Note(
      title: 'my plan for the future me',
      content: 'Imagine the perfect life, the perfect family, dream house...',
    ),
    Note(
      title: 'how I found a new dream',
      content: 'Today my wish has come true – to devote the whole d...',
    ),
    Note(
      title: 'my plan for the future me',
      content: 'Imagine the perfect life, the perfect family, dream house...',
    ),
    // Add more notes here...
  ].obs;

  List<Note> get filteredNotes {
    if (selectedFilter.isEmpty) return notes;
    return notes.where((note) {
      return note.title.contains(selectedFilter.value);
    }).toList();
  }

  void setFilter(String filter) {
    if (selectedFilter.value == filter) {
      selectedFilter.value = '';
    } else {
      selectedFilter.value = filter;
    }
  }
}

class Note {
  final String title;
  final String content;

  Note({
    required this.title,
    required this.content,
  });
}
