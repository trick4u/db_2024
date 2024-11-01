import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';


import '../models/note_model.dart';
import '../services/toast_util.dart';

class NoteTakingController extends GetxController {
  final titleController = TextEditingController();
  final subTasks = <TextEditingController>[].obs;
  final _canAddSubTask = false.obs;
  final _canSave = false.obs;
  final _selectedDate = DateTime.now().obs;
  final _notes = <Note>[].obs;
  final isLoading = true.obs;
  final _subtaskLengths = <String, int>{}.obs;

  final isLoadingMore = false.obs;
  final _completedNotesCount = 0.obs;
  final _incompleteNotesCount = 0.obs;

  int get completedNotesCount => _completedNotesCount.value;
  int get incompleteNotesCount => _incompleteNotesCount.value;

  bool get canAddSubTask => _canAddSubTask.value;
  bool get canSave => _canSave.value;
  DateTime get selectedDate => _selectedDate.value;
  List<Note> get notes => _notes;
  static const int maxNotes = 20;

  static const int maxSubTasks = 10;
  static const int notesPerPage = 10;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => FirebaseAuth.instance.currentUser;
  bool get canAddMoreNotes => _notes.length < maxNotes;
  DocumentSnapshot? _lastDocument;
  bool _hasMoreNotes = true;
  final AudioPlayer _successPlayer = AudioPlayer();
  bool _isSoundLoaded = false;

  int getSubtaskLength(String noteId) {
    final note = _notes.firstWhere((note) => note.id == noteId,
        orElse: () =>
            Note(title: '', subTasks: [], date: DateTime.now(), userId: ''));

    return note.subTasks.length;
  }

  CollectionReference get notesCollection {
    return _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .collection('notes');
  }

  @override
  void onInit() {
    super.onInit();
    _loadSound();
    ever(_notes, (_) {
      _updateSubtaskLengths(_);
      _updateNoteCounts();
    });
    ever(_notes, _updateSubtaskLengths);
    ever(subTasks, (_) => _updateState());
    titleController.addListener(_updateState);
    fetchNotes();
  }

  Future<void> _loadSound() async {
    try {
      await _successPlayer.setSource(AssetSource('success.mp3'));
      await _successPlayer.setVolume(1.0);
      _isSoundLoaded = true;
    } catch (e) {
      print('Error loading sound: $e');
      _isSoundLoaded = false;
    }
  }

  Future<void> _playCompletionSound() async {
    if (!_isSoundLoaded) return;
    
    try {
      await _successPlayer.seek(Duration.zero);
      await _successPlayer.resume();
    } catch (e) {
      print('Error playing completion sound: $e');
      // Try to reload and play again
      try {
        await _loadSound();
        await _successPlayer.resume();
      } catch (retryError) {
        print('Error retrying completion sound: $retryError');
      }
    }
  }

  void _updateNoteCounts() {
    _completedNotesCount.value =
        _notes.where((note) => note.isCompleted).length;
    _incompleteNotesCount.value =
        _notes.where((note) => !note.isCompleted).length;
  }

 Future<void> toggleNoteCompletion(String noteId) async {
    try {
      int index = _notes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        bool newCompletionStatus = !_notes[index].isCompleted;
        Note updatedNote = _notes[index].copyWith(
          isCompleted: newCompletionStatus,
          updatedAt: DateTime.now(),
        );

        await notesCollection.doc(noteId).update(updatedNote.toMap());

        // Update the note in the list
        _notes[index] = updatedNote;

        // Play sound only when the note is marked as complete
        if (newCompletionStatus) {
          await _playCompletionSound();
        }

        // Update the note counts
        _updateNoteCounts();

        update();

        ToastUtil.showToast(
          "Note Updated",
          newCompletionStatus
              ? "Note marked as completed"
              : "Note marked as incomplete",
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error toggling note completion: $e');
      ToastUtil.showToast('Error', 'Failed to update note status');
    }
  }

  void _updateSubtaskLengths(List<Note> notes) {
    for (var note in notes) {
      _subtaskLengths[note.id ?? ''] = note.subTasks.length;
    }
  }

  Future<void> deleteSubTask(String noteId, int subTaskIndex) async {
    if (currentUser == null) {
      ToastUtil.showToast('Error', 'You must be logged in to update notes');
      return;
    }

    try {
      int noteIndex = _notes.indexWhere((note) => note.id == noteId);
      if (noteIndex == -1) {
        throw Exception('Note not found');
      }

      Note note = _notes[noteIndex];
      List<String> updatedSubTasks = List.from(note.subTasks);
      updatedSubTasks.removeAt(subTaskIndex);

      Note updatedNote = note.copyWith(
        subTasks: updatedSubTasks,
        updatedAt: DateTime.now(),
      );

      await notesCollection.doc(noteId).update(updatedNote.toMap());
      _notes[noteIndex] = updatedNote;
      _notes.refresh();

      ToastUtil.showToast('Success', 'Sub-task deleted successfully');
    } catch (e) {
      print('Error deleting sub-task: $e');
      ToastUtil.showToast('Error', 'Failed to delete sub-task');
    }
  }

  Future<void> updateNote(String noteId, Note updatedNote) async {
    if (currentUser == null) {
      ToastUtil.showToast('Error', 'You must be logged in to update notes');
      return;
    }

    try {
      // Filter out empty subtasks
      updatedNote = updatedNote.copyWith(
        subTasks:
            updatedNote.subTasks.where((task) => task.isNotEmpty).toList(),
      );

      await notesCollection.doc(noteId).update(updatedNote.toMap());
      int index = _notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        _notes[index] = updatedNote;
      }
      _notes.refresh();
      Get.back(); // Close the bottom sheet
      clearFields();
      ToastUtil.showToast('Success', 'Note updated successfully');
    } catch (e) {
      print('Error updating note: $e');
      ToastUtil.showToast('Error', 'Failed to update note');
    }
  }

  void _updateState() {
    if (subTasks.isEmpty) {
      _canAddSubTask.value = titleController.text.trim().isNotEmpty &&
          subTasks.length < maxSubTasks;
    } else {
      _canAddSubTask.value =
          subTasks.last.text.trim().isNotEmpty && subTasks.length < maxSubTasks;
    }
    _canSave.value = titleController.text.trim().isNotEmpty;
  }

  void initializeForEditing(Note note) {
    titleController.text = note.title;
    subTasks.clear();
    for (var subTask in note.subTasks) {
      subTasks.add(TextEditingController(text: subTask));
    }
    _selectedDate.value = note.date;
    _updateState();
  }

  void addSubTask() {
    if (canAddSubTask && subTasks.length < maxSubTasks) {
      subTasks.add(TextEditingController());
      _updateState();
    }
  }

  void updateSubTask(int index, String value) {
    if (index >= 0 && index < subTasks.length) {
      subTasks[index].text = value;
      _updateState();
    }
  }

  void removeSubTask(int index) {
    if (index >= 0 && index < subTasks.length) {
      subTasks[index].dispose();
      subTasks.removeAt(index);
      _updateState();
    }
  }

  void updateSelectedDate(DateTime newDate) {
    _selectedDate.value = newDate;
  }

  Future<void> saveNote() async {
    if (currentUser == null) {
      ToastUtil.showToast('Error', 'You must be logged in to save notes');
      return;
    }

    if (canSave && canAddMoreNotes) {
      final note = Note(
        title: titleController.text.trim(),
        subTasks: subTasks
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
        date: selectedDate,
        userId: currentUser!.uid,
      );

      try {
        DocumentReference docRef = await notesCollection.add(note.toMap());
        note.id = docRef.id;
        _notes.add(note);
        Get.back(); // Close the bottom sheet
        clearFields();
        ToastUtil.showToast('Success', 'Note saved successfully');
      } catch (e) {
        print('Error saving note: $e');
        ToastUtil.showToast('Error', 'Failed to save note');
      }
    } else if (!canAddMoreNotes) {
      ToastUtil.showToast('Error', 'Maximum number of notes (20) reached');
    }
  }

  Future<void> fetchNotes({bool loadMore = false}) async {
    if (currentUser == null) return;
    if (loadMore && !_hasMoreNotes) return;

    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }

      Query query =
          notesCollection.orderBy('date', descending: true).limit(notesPerPage);

      if (loadMore && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        _hasMoreNotes = false;
        return;
      }

      _lastDocument = querySnapshot.docs.last;

      final newNotes = querySnapshot.docs
          .map(
              (doc) => Note.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      if (loadMore) {
        _notes.addAll(newNotes);
      } else {
        _notes.assignAll(newNotes);
      }

      _hasMoreNotes = querySnapshot.docs.length == notesPerPage;
    } catch (e) {
      print('Error fetching notes: $e');
      ToastUtil.showToast('Error', 'Failed to fetch notes');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> deleteNote(String noteId) async {
    if (currentUser == null) return;

    try {
      await notesCollection.doc(noteId).delete();
      _notes.removeWhere((note) => note.id == noteId);
      _subtaskLengths.remove(noteId);
      ToastUtil.showToast('Success', 'Note deleted successfully');
    } catch (e) {
      print('Error deleting note: $e');
      ToastUtil.showToast('Error', 'Failed to delete note');
    }
  }

  Future<void> deleteAllNotes() async {
    if (currentUser == null) {
      ToastUtil.showToast('Error', 'You must be logged in to delete notes');
      return;
    }

    try {
      // Get all documents in the notes collection
      QuerySnapshot querySnapshot = await notesCollection.get();

      // Create a batch write operation
      WriteBatch batch = _firestore.batch();

      // Add delete operations to the batch
      for (DocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();

      // Clear the local list of notes
      _notes.clear();

      ToastUtil.showToast('Success', 'All notes have been deleted');
    } catch (e) {
      print('Error deleting all notes: $e');
      ToastUtil.showToast('Error', 'Failed to delete all notes');
    }
  }

  void clearFields() {
    titleController.clear();
    for (var controller in subTasks) {
      controller.dispose();
    }
    subTasks.clear();
    _selectedDate.value = DateTime.now();
    _updateState();
  }

  @override
  void onClose() {
    _successPlayer.dispose();
    titleController.dispose();
    for (var controller in subTasks) {
      controller.dispose();
    }
    super.onClose();
  }
}
