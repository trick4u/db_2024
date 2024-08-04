import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuickEventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final Color color;
  final bool hasReminder;
   DateTime? reminderTime;

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
  });

  factory QuickEventModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return QuickEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] != null ? (data['startTime'] as Timestamp).toDate() : null,
      endTime: data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null,
      color: Color(data['color'] ?? 0xFF000000),
      hasReminder: data['hasReminder'] ?? false,
      reminderTime: data['reminderTime'] != null ? (data['reminderTime'] as Timestamp).toDate() : null,
    );
  }
}