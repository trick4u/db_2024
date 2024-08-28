import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String reminder;
  final int time;
  final bool isCompleted;
  final DateTime createdAt;
  final bool repeat;
  final DateTime? triggerTime;
  final int? notificationId;

  ReminderModel({
    required this.id,
    required this.reminder,
    required this.time,
    required this.isCompleted,
    required this.createdAt,
    required this.repeat,
    required this.triggerTime,
    this.notificationId,
  });

  factory ReminderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReminderModel(
      id: doc.id,
      reminder: data['reminder'] ?? '',
      time: data['time'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      repeat: data['repeat'] ?? false,
      triggerTime: data['triggerTime'] != null
          ? (data['triggerTime'] as Timestamp).toDate()
          : null,
      notificationId: data['notificationId'],
    );
  }
}
