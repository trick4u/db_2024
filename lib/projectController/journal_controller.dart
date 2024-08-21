

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';



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

// Journal controller
class  JournalController extends GetxController {
  final journalEntries = <JournalEntry>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    _loadEntries();
  }

  void _loadEntries() {
    if (currentUser != null) {
      _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('journal_entries')
          .orderBy('date', descending: false)  // Order by date in ascending order
          .snapshots()
          .listen((snapshot) {
        journalEntries.assignAll(
          snapshot.docs.map((doc) => JournalEntry.fromFirestore(doc)).toList(),
        );
      });
    }
  }

  Future<void> addEntry(JournalEntry entry) async {
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('journal_entries')
          .add(entry.toFirestore());
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<void> removeEntry(String id) async {
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('journal_entries')
          .doc(id)
          .delete();
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<void> updateEntry(JournalEntry updatedEntry) async {
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('journal_entries')
          .doc(updatedEntry.id)
          .update(updatedEntry.toFirestore());
    } else {
      throw Exception('User not authenticated');
    }
  }
}