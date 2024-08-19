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
  final DateTime? reminderTime;
  final bool? isCompleted;
  final DateTime? createdAt;
  final bool? editedAfterCompletion;
  final DateTime? completedAt;
  final bool notificationDisplayed;

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
    this.createdAt,
    this.editedAfterCompletion,
    this.completedAt,
    this.notificationDisplayed = false,
  });

  factory QuickEventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      }
      return null;
    }

    return QuickEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: parseTimestamp(data['date']) ?? DateTime.now(),
      startTime: parseTimestamp(data['startTime']),
      endTime: parseTimestamp(data['endTime']),
      color: Color(data['color'] ?? 0xFF000000),
      hasReminder: data['hasReminder'] ?? false,
      reminderTime: parseTimestamp(data['reminderTime']),
      isCompleted: data['isCompleted'],
      createdAt: parseTimestamp(data['createdAt']),
      editedAfterCompletion: data['editedAfterCompletion'],
      completedAt: parseTimestamp(data['completedAt']),
      notificationDisplayed: data['notificationDisplayed'] ?? false,
    );
  }
}