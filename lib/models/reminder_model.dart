import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String reminder;
  final int time;
  final bool isReminderSet;
  final DateTime createdAt;
  final bool repeat;
  final bool isCompleted;

  ReminderModel({
    required this.id,
    required this.reminder,
    required this.time,
    required this.isReminderSet,
    required this.createdAt,
    required this.repeat,
    this.isCompleted = false,
  });

  factory ReminderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ReminderModel(
      id: doc.id,
      reminder: data['reminder'] ?? '',
      time: data['time'] ?? 0,
      isReminderSet: data['isReminderSet'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      repeat: data['repeat'] ?? false,
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}
