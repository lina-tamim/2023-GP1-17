import 'dart:core';

class CardQuestion {
  final String title;
  late final String description;
  final List<String> topics;
  final String userId;
  String? userPhotoUrl;
  String? username;
  String questionDocId;
  String userType;
  String reason;
  String reportedItemId;

  CardQuestion({
    required this.title,
    required this.description,
    required this.topics,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.questionDocId,
    required this.userType,
    required this.reason,
    required this.reportedItemId,
  });

  Map<String, dynamic> toJson() => {
        'postTitle': title,
        'postDescription': description,
        'selectedInterests': topics,
        'userId': userId,
        'username': '',
        'userPhotoUrl': userPhotoUrl,
        'questionDocId': questionDocId,
        'userType': userType,
        'reason': reason,
        'reportedItemId': reportedItemId,
      };

  static CardQuestion fromJson(Map<String, dynamic> json) => CardQuestion(
        title: json['postTitle'],
        description: json['postDescription'],
        topics: List<String>.from(json['selectedInterests']),
        userId: json['userId'],
        questionDocId: json['questionDocId'] ?? '',
        username: json['username'] ?? '',
        userPhotoUrl: json['userPhotoUrl'] as String?,
        userType: json['userType'] ?? '',
        reason: json['reason'] ?? '',
        reportedItemId: json['reportedItemId'] ?? '',
      );
}
