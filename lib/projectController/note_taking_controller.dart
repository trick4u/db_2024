import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/note_model.dart';


class NoteTakingController extends GetxController {
  final titleController = TextEditingController();
  final subTasks = <TextEditingController>[].obs;
  final _canAddSubTask = false.obs;
  final _canSave = false.obs;
  final _selectedDate = DateTime.now().obs;
  final _notes = <Note>[].obs;
  final isLoading = true.obs;

  bool get canAddSubTask => _canAddSubTask.value;
  bool get canSave => _canSave.value;
  DateTime get selectedDate => _selectedDate.value;
  List<Note> get notes => _notes;

  static const int maxSubTasks = 10;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  CollectionReference get notesCollection {
    return _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .collection('notes');
  }

  @override
  void onInit() {
    super.onInit();
    ever(subTasks, (_) => _updateState());
    titleController.addListener(_updateState);
    fetchNotes();
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
      Get.snackbar('Error', 'You must be logged in to save notes');
      return;
    }

    if (canSave) {
      final note = Note(
        title: titleController.text.trim(),
        subTasks: subTasks.map((controller) => controller.text.trim()).toList(),
        date: selectedDate,
        userId: currentUser!.uid,
      );

      try {
        DocumentReference docRef = await notesCollection.add(note.toMap());
        note.id = docRef.id;
        _notes.add(note);
        Get.back(); // Close the bottom sheet
        clearFields();
        Get.snackbar('Success', 'Note saved successfully');
      } catch (e) {
        print('Error saving note: $e');
        Get.snackbar('Error', 'Failed to save note');
      }
    }
  }

  Future<void> updateNote(String noteId) async {
    if (currentUser == null) {
      Get.snackbar('Error', 'You must be logged in to update notes');
      return;
    }

    if (canSave) {
      final updatedNote = Note(
        id: noteId,
        title: titleController.text.trim(),
        subTasks: subTasks.map((controller) => controller.text.trim()).toList(),
        date: selectedDate,
        userId: currentUser!.uid,
      );

      try {
        await notesCollection.doc(noteId).update(updatedNote.toMap());
        int index = _notes.indexWhere((n) => n.id == noteId);
        if (index != -1) {
          _notes[index] = updatedNote;
        }
        Get.back(); // Close the bottom sheet
        clearFields();
        Get.snackbar('Success', 'Note updated successfully');
      } catch (e) {
        print('Error updating note: $e');
        Get.snackbar('Error', 'Failed to update note');
      }
    }
  }

  Future<void> fetchNotes() async {
    if (currentUser == null) return;

    try {
      isLoading.value = true;
      QuerySnapshot querySnapshot =
          await notesCollection.orderBy('date', descending: true).get();
      _notes.value = querySnapshot.docs
          .map(
              (doc) => Note.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching notes: $e');
      Get.snackbar('Error', 'Failed to fetch notes');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNote(String noteId) async {
    if (currentUser == null) return;

    try {
      await notesCollection.doc(noteId).delete();
      _notes.removeWhere((note) => note.id == noteId);
      Get.snackbar('Success', 'Note deleted successfully');
    } catch (e) {
      print('Error deleting note: $e');
      Get.snackbar('Error', 'Failed to delete note');
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
    titleController.dispose();
    for (var controller in subTasks) {
      controller.dispose();
    }
    super.onClose();
  }
}