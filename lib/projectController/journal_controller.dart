import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/app_theme.dart';

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
    };
  }
}

class JournalController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  Rx<DateTime> focusedDay = DateTime.now().obs;
  Rx<DateTime> selectedDay = DateTime.now().obs;
  RxList<JournalEntry> entries = <JournalEntry>[].obs;
  Rx<CalendarFormat> calendarFormat = CalendarFormat.week.obs;

  // New properties for journal entry editing
  late TextEditingController titleController;
  late TextEditingController contentController;
  Rx<JournalEntry?> currentEntry = Rx<JournalEntry?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchEntries(selectedDay.value);
    titleController = TextEditingController();
    contentController = TextEditingController();
  }

  void setFocusedDay(DateTime day) {
    focusedDay.value = day;
    update();
  }

  void setSelectedDay(DateTime day) {
    selectedDay.value = day;
    setFocusedDay(day);
    fetchEntries(day);
    update();
  }

  void toggleCalendarFormat() {
    calendarFormat.value = calendarFormat.value == CalendarFormat.month
        ? CalendarFormat.week
        : CalendarFormat.month;
    update();
  }

  void fetchEntries(DateTime day) {
    if (currentUser == null) return;

    DateTime startOfDay = DateTime(day.year, day.month, day.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .collection('journal_entries')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .listen((querySnapshot) {
      entries.value = querySnapshot.docs
          .map((doc) => JournalEntry.fromFirestore(doc))
          .toList();
      update();
    });
  }

  Future<void> addEntry(String title, String content) async {
    if (currentUser == null) return;

    JournalEntry newEntry = JournalEntry(
      id: '',
      title: title,
      content: content,
      date: selectedDay.value,
    );

    await _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .collection('journal_entries')
        .add(newEntry.toFirestore());

    fetchEntries(selectedDay.value);
  }

  Future<void> updateEntry(JournalEntry entry, String title, String content) async {
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .collection('journal_entries')
        .doc(entry.id)
        .update({
      'title': title,
      'content': content,
    });

    fetchEntries(selectedDay.value);
  }

  Future<void> deleteEntry(String entryId) async {
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .collection('journal_entries')
        .doc(entryId)
        .delete();

    fetchEntries(selectedDay.value);
  }

  bool hasEntriesForDay(DateTime day) {
    return entries.any((entry) =>
        entry.date.year == day.year &&
        entry.date.month == day.month &&
        entry.date.day == day.day);
  }

  // New methods for journal entry editing
  void initEntryEdit(JournalEntry? entry) {
    currentEntry.value = entry;
    titleController.text = entry?.title ?? '';
    contentController.text = entry?.content ?? '';
  }

  void saveEntry() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    
    if (title.isEmpty && content.isEmpty) {
      Get.back(); // Close the screen without saving if both fields are empty
      return;
    }

    if (currentEntry.value == null) {
      addEntry(title, content);
    } else {
      updateEntry(currentEntry.value!, title, content);
    }
    Get.back(); // Return to the previous screen
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}