import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuickEventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  late final DateTime? startTime;
  late final DateTime? endTime;
  final Color color;
  final bool hasReminder;
  DateTime? reminderTime;
  bool? isCompleted;
  final DateTime createdAt;
  final bool editedAfterCompletion;
  final DateTime? completedAt;  // New field

  QuickEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.startTime,
    this.endTime,
    required this.color,
    required this.hasReminder,
    this.reminderTime,
    this.isCompleted,
    required this.createdAt,
    this.editedAfterCompletion = false,
    this.completedAt,  // Add this to the constructor
  });

  factory QuickEventModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return QuickEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      color: Color(data['color'] ?? 0xFF000000),
      hasReminder: data['hasReminder'] ?? false,
      reminderTime: data['reminderTime'] != null
          ? (data['reminderTime'] as Timestamp).toDate()
          : null,
      isCompleted: data['isCompleted'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      editedAfterCompletion: data['editedAfterCompletion'] ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,  // Parse completedAt from Firestore
    );
  }
}