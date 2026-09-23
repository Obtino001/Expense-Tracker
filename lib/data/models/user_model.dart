import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.currency = 'USD',
    this.fcmTokens = const <String>[],
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String currency;
  final List<String> fcmTokens;
  final DateTime? createdAt;

  String get initials {
    final List<String> parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? currency,
    List<String>? fcmTokens,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currency: currency ?? this.currency,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      createdAt: createdAt,
    );
  }

  // ---------- Firestore ----------
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'currency': currency,
        'fcmTokens': fcmTokens,
        // Server-resolved timestamp on create.
        'createdAt': createdAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(createdAt!),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      fcmTokens: List<String>.from(json['fcmTokens'] as List<dynamic>? ??
          const <dynamic>[]),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
