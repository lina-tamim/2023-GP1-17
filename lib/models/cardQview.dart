//Full code, m s
//GP discussion
import 'dart:core';

class CardQview {
  final int id;
  final String postType;
  final String title;
  final String description;
  final List<String> topics;
  final String userId;
  String? docId;
  String? username;
  String? userPhotoUrl; // Add userPhotoUrl property

  CardQview({
    required this.id,
    required this.postType,
    required this.title,
    required this.description,
    required this.topics,
    required this.userId,
    this.docId ='' ,
    required this.username,
    required this.userPhotoUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dropdownValue': postType,
        'textFieldValue': title,
        'largeTextFieldValue': description,
        'selectedInterests': topics,
        'userId': userId,
        'docId': docId,
        'username': username,
        'userPhotoUrl': userPhotoUrl, // Update property name to userPhotoUrl
      };

  static CardQview fromJson(Map<String, dynamic> json) => CardQview(
        id: json['id'],
        postType: json['dropdownValue'],
        title: json['textFieldValue'],
        description: json['largeTextFieldValue'],
        topics: List<String>.from(json['selectedInterests']),
        userId: json['userId'],
        docId: json['docId'] ?? '',
        username: json['username'] ?? '',
        userPhotoUrl: json['userPhotoUrl'] as String?, // Update property name to userPhotoUrl
      );
}

//TECHXCEL