import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String title;
  int priority;
  bool isFrog;

  Task({required this.id, required this.title, required this.priority, required this.isFrog});

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      priority: data['priority'] ?? 0,
      isFrog: data['isFrog'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'priority': priority,
      'isFrog': isFrog,
    };
  }
}