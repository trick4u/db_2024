import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String reminder;
  final int time;
  final bool repeat;
  final DateTime? triggerTime;
  final DateTime? createdAt;
  final int? notificationId;
  int triggerCount;
  final int repeatCount;

  ReminderModel({
    required this.id,
    required this.reminder,
    required this.time,
    required this.repeat,
    this.triggerTime,
    this.createdAt,
    this.notificationId,
    this.triggerCount = 0,
    this.repeatCount = 0,
  });

  factory ReminderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReminderModel(
      id: doc.id,
      reminder: data['reminder'] ?? '',
      time: data['time'] ?? 0,
      repeat: data['repeat'] ?? false,
      triggerTime: data['triggerTime'] != null
          ? (data['triggerTime'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      notificationId: data['notificationId'],
      triggerCount: data['triggerCount'] ?? 0,
      repeatCount: data['repeatCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reminder': reminder,
      'time': time,
      'repeat': repeat,
      'triggerTime':
          triggerTime != null ? Timestamp.fromDate(triggerTime!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'triggerCount': triggerCount,
      'repeatCount': repeatCount,
    };
  }
}
