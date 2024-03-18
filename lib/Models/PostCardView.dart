import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardFTview {
  final String title;
  final String description;
  final DateTime date;
  final List<String> topics;
  final String userId;
  final String docId;
  String? username;
  String? userPhotoUrl;
  String email;
  String userType;
  String? teamDocId;
  DateTime postedDate;
  int noOfAnswers;

  CardFTview({
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
    required this.teamDocId,
    required this.postedDate,
    required this.noOfAnswers,
  });

  Map<String, dynamic> toJson() => {
        'postTitle': title,
        'postDescription': description,
        'deadlineDate': date,
        'selectedInterests': topics,
        'userId': userId,
        'docId': docId,
        'username': username,
        'userPhotoUrl': userPhotoUrl,
        'email': email,
        'userType': userType,
        'teamDocId': teamDocId,
        'postedDate': Timestamp.fromDate(postedDate),
        'noOfAnswers': noOfAnswers,
      };

  static CardFTview fromJson(Map<String, dynamic> json) => CardFTview(
        title: json['postTitle'],
        description: json['postDescription'],
        topics: List<String>.from(json['selectedInterests']),
        date: (json['deadlineDate'] as Timestamp).toDate(),
        userId: json['userId'],
        username: json['username'] ?? '',
        docId: json['docId'],
        userPhotoUrl: json['userPhotoUrl'] as String?,
        email: json['email'] ?? '',
        userType: json['userType'] ?? '',
        teamDocId: json['teamDocId'],
        postedDate: (json['postedDate'] as Timestamp).toDate(),
        noOfAnswers: json['noOfAnswers'] as int? ?? 0,
      );
}
