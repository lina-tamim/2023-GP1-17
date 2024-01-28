import 'dart:core';
class CardQuestion {
  final int id;
  final String title;
  final String description;
  final List<String> topics;
  final String userId;
  String? userPhotoUrl;
  String? username;
  String questionDocId;

  CardQuestion({
    required this.id,
    required this.title,
    required this.description,
    required this.topics,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.questionDocId,
  });

  Map<String, dynamic> toJson() => {
        'questionCount': id,
        'postTitle': title,
        'postDescription': description,
        'selectedInterests': topics,
        'userId': userId,
        'username': '',
        'userPhotoUrl': userPhotoUrl,
        'questionDocId': questionDocId,
      };

  static CardQuestion fromJson(Map<String, dynamic> json) => CardQuestion(
        id: json['questionCount'],
        title: json['postTitle'],
        description: json['postDescription'],
        topics: List<String>.from(json['selectedInterests']),
        userId: json['userId'],
        questionDocId: json['questionDocId'] ?? '',
        username: json['username'] ?? '',
        userPhotoUrl: json['userPhotoUrl'] as String?,
      );
}

 