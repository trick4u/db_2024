
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalsModel {
  Timestamp? createdAt;
  String? goal;

  GoalsModel({this.createdAt, this.goal});

  GoalsModel.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    goal = json['goal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['goal'] = goal;
    return data;
  }


}
