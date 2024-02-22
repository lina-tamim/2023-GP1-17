import 'dart:core';

class CardQview {
  final String title;
  final String description;
  final List<String> topics;
  final String userId;
  String? docId;
  String? username;
  String? userPhotoUrl;
  String questionDocId;
  String? reason;
  String userType;
  String reportedItemId;
  String reportDocid;
  String? status;
  List<String>? reasons;
  List<String>? reportIds;

  CardQview(
      {required this.title,
      required this.description,
      required this.topics,
      required this.userId,
      this.docId,
      required this.username,
      required this.userPhotoUrl,
      required this.questionDocId,
      this.reason,
      required this.userType,
      required this.reportedItemId, // Make sure it's included in the constructor
      required this.reportDocid,
      required this.status

// Add the reason property
      });

  Map<String, dynamic> toJson() => {
        'postTitle': title,
        'postDescription': description,
        'selectedInterests': topics,
        'userId': userId,
        'docId': docId,
        'username': username,
        'userPhotoUrl': userPhotoUrl,
        'questionDocId': questionDocId,
        'reason': reason,
        'userType': userType,
        'reportedItemId': reportedItemId,
        'reportDocid': reportDocid,
        'status': status,
      };

  static CardQview fromJson(Map<String, dynamic> json) => CardQview(
        title: json['postTitle'],
        description: json['postDescription'],
        topics: List<String>.from(json['selectedInterests']),
        userId: json['userId'],
        docId: json['docId'],
        username: json['username'],
        userPhotoUrl: json['userPhotoUrl'] as String?,
        questionDocId: json['questionDocId'],
        reason: json['reason'] as String?,
        userType: json['userType'] ?? '',
        reportedItemId: json['reportedItemId'] ?? '',
        reportDocid: json['reportDocid'] ?? '',
        status: json['status'] as String?,
      );
      
}
