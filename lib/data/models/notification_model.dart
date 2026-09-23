import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum NotificationType { info, success, warning, alert }

@immutable
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  final bool isRead;

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        message: message,
        time: time,
        type: type,
        isRead: isRead ?? this.isRead,
      );

  // ---------- Firestore ----------
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'message': message,
        'time': Timestamp.fromDate(time),
        'type': type.name,
        'isRead': isRead,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      time: (json['time'] as Timestamp).toDate(),
      type: NotificationType.values.byName(json['type'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
