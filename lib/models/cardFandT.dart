import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardFT {
  final String postType;
  final String title;
  final String description;
  final DateTime date;
  final List<String> topics;
  final String userId;
  //final String docId;
  String username;

  CardFT({
    required this.postType,
    required this.title,
    required this.description,
    required this.date,
    required this.topics,
    required this.userId,
    //required this.docId,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        'dropdownValue': postType,
        'textFieldValue': title,
        'largeTextFieldValue': description,
        'selectedDate': date,
        'selectedInterests': topics,
        'userId': userId,
        //'docId': docId,
        'username': '',
      };

  static CardFT fromJson(Map<String, dynamic> json) => CardFT(
      postType: json['dropdownValue'],
      title: json['textFieldValue'],
      description: json['largeTextFieldValue'],
      topics: List<String>.from(json['selectedInterests']),
      date: (json['selectedDate'] as Timestamp).toDate(),
      userId: json['userId'],
      username: json['username'] ?? '',
      //docId: json['docId']
      );
}

//TECHXCEL