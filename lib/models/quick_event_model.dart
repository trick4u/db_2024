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
  bool hasReminder;
  final DateTime? reminderTime;
  final bool? isCompleted;
  final DateTime createdAt;
  final bool? editedAfterCompletion;
  final DateTime? completedAt;
  DateTime? lastNotificationDisplayed;
  final String? repetition;
  

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
    this.editedAfterCompletion,
    this.completedAt,
    this.lastNotificationDisplayed,
    this.repetition,
  });

  factory QuickEventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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
      isCompleted: data['isCompleted'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      editedAfterCompletion: data['editedAfterCompletion'],
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      lastNotificationDisplayed: data['lastNotificationDisplayed'] != null
          ? (data['lastNotificationDisplayed'] as Timestamp).toDate()
          : null,
      repetition: data['repetition'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'color': color.value,
      'hasReminder': hasReminder,
      'reminderTime':
          reminderTime != null ? Timestamp.fromDate(reminderTime!) : null,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'editedAfterCompletion': editedAfterCompletion,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'lastNotificationDisplayed': lastNotificationDisplayed != null
          ? Timestamp.fromDate(lastNotificationDisplayed!)
          : null,
    };
  }

  QuickEventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    bool? hasReminder,
    DateTime? reminderTime,
    bool? isCompleted,
    DateTime? createdAt,
    bool? editedAfterCompletion,
    DateTime? completedAt,
    DateTime? lastNotificationDisplayed,
  }) {
    return QuickEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      editedAfterCompletion:
          editedAfterCompletion ?? this.editedAfterCompletion,
      completedAt: completedAt ?? this.completedAt,
      lastNotificationDisplayed:
          lastNotificationDisplayed ?? this.lastNotificationDisplayed,
      repetition: repetition ?? repetition,
    );
  }
}
