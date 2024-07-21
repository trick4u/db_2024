import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuickEventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final Color color;
  DateTime? startTime;
  DateTime? endTime;

  

  QuickEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.color,
    this.startTime,
    this.endTime
  });

  factory QuickEventModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return QuickEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      color: Color(data['color'] ?? Colors.blue.value),
      startTime: data['startTime'] != null ? (data['startTime'] as Timestamp).toDate() : null,
      endTime: data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null,
    
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'color': color.value,
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
    
    };
  }
}
