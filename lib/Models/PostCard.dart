import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardFT {
  final String title;
  final String description;
  final DateTime date;
  final List<String> topics;
  final String userId;
  //final String? docId;
  String docId;
  String? username;
  String? userPhotoUrl;
  String email;
  String userType;
  String? reason;
  String? teamDocId;
  String? projectDocId;
  String reportDocid;

  CardFT({
    required this.title,
    required this.description,
    required this.date,
    required this.topics,
    required this.userId,
    this.docId = '',
    required this.username,
    required this.userPhotoUrl,
    required this.email,
    required this.userType,
    this.reason,
    required this.teamDocId,
    required this.projectDocId, // Provide a default value or make it nullable
    required this.reportDocid,
  });

  Map<String, dynamic> toJson() => {
        'postTitle': title,
        'postDescription': description,
        'deadlineDate': date,
        'selectedInterests': topics,
        'userId': userId,
        'docId': docId,
        'username': '',
        'userPhotoUrl': userPhotoUrl,
        'email': email,
        'userType': userType,
        'reason': reason,
        'teamDocId': teamDocId,
        'projectDocId': projectDocId,
        'reportDocid': reportDocid,
      };

  static CardFT fromJson(Map<String, dynamic> json) => CardFT(
        title: json['postTitle'],
        description: json['postDescription'],
        topics: List<String>.from(json['selectedInterests']),
        date: (json['deadlineDate'] as Timestamp).toDate(),
        userId: json['userId'],
        username: json['username'] ?? '',
        userPhotoUrl: json['userPhotoUrl'] as String?,
        docId: json['docId'] ?? '',
        email: json['email'] ?? '',
        userType: json['userType'] ?? '',
        reason: json['reason'] as String?,
        teamDocId: json['teamDocId'],
        projectDocId: json['projectDocId'],
        reportDocid: json['reportDocid'] ?? '',
      );
}
