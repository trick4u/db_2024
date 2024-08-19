

import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String? id;
  String title;
  List<String> subTasks;
  DateTime date;
  DateTime createdAt;
  DateTime updatedAt;
  String userId;

  Note({
    this.id,
    required this.title,
    required this.subTasks,
    required this.date,
    required this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subTasks': subTasks,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
    };
  }

  static Note fromMap(Map<String, dynamic> map, String id) {
    return Note(
      id: id,
      title: map['title'] as String,
      subTasks: List<String>.from(map['subTasks']),
      date: (map['date'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      userId: map['userId'] as String,
    );
  }
}