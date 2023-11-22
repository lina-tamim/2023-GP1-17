//Full code, m S
//GP discussion
//EDIT +CALNDER COMMIT

import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardFT {
  final String postType;
  final String title;
  final String description;
  final DateTime date;
  final List<String> topics;
  final String userId;
  final String? docId;
  String? username;
  String? userPhotoUrl;

  CardFT(
      {required this.postType,
      required this.title,
      required this.description,
      required this.date,
      required this.topics,
      required this.userId,
      this.docId = '',
      required this.username,
      required this.userPhotoUrl});

  Map<String, dynamic> toJson() => {
        'dropdownValue': postType,
        'textFieldValue': title,
        'largeTextFieldValue': description,
        'selectedDate': date,
        'selectedInterests': topics,
        'userId': userId,
        'docId': docId,
        'username': '',
        'userPhotoUrl': userPhotoUrl,
      };

  static CardFT fromJson(Map<String, dynamic> json) => CardFT(
      postType: json['dropdownValue'],
      title: json['textFieldValue'],
      description: json['largeTextFieldValue'],
      topics: List<String>.from(json['selectedInterests']),
      date: (json['selectedDate'] as Timestamp).toDate() ,
      userId: json['userId'],
      username: json['username'] ?? '',
      userPhotoUrl: json['userPhotoUrl'] as String?,
      docId: json['docId'] ?? '');
}

//TECHXCEL