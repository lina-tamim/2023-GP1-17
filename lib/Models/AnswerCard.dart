import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardAnswer {
  String questionDocId;
  String userId;
  String answerText;
  int upvoteCount;
  String? username;
  List<String> upvotedUserIds;
  String docId;
  String? userPhotoUrl;
  String? reason;
  String userType;
  String reportedItemId;
  String reportDocid;
  List<String>? reasons;
  List<String>? reportDocids;
  DateTime postedDate;
  DateTime reportDate;

  CardAnswer({
    required this.questionDocId,
    required this.userId,
    required this.answerText,
    required this.upvoteCount,
    this.upvotedUserIds = const [],
    this.docId = '',
    required this.username,
    required this.userPhotoUrl,
    this.reason,
    required this.userType,
    required this.reportedItemId,
    required this.reportDocid,
    required this.postedDate,
    required this.reportDate,
  });

  Map<String, dynamic> toJson() => {
        'questionDocId': questionDocId,
        'userId': userId,
        'answerText': answerText,
        'upvoteCount': upvoteCount,
        'username': username,
        'upvotedUserIds': upvotedUserIds,
        'docId': docId,
        'userPhotoUrl': userPhotoUrl,
        'reason': reason,
        'userType': userType,
        'reportedItemId': reportedItemId,
        'reportDocid': reportDocid,
        'postedDate': Timestamp.fromDate(postedDate),
        'reportDate': Timestamp.fromDate(reportDate),
      };

  factory CardAnswer.fromJson(Map<String, dynamic> json) {
    return CardAnswer(
      questionDocId: json['questionId'],
      userId: json['userId'] as String,
      answerText: json['answerText'] as String,
      upvoteCount: json['upvoteCount'] as int,
      upvotedUserIds: List<String>.from(json['upvotedUserIds'] ?? []),
      docId: json['docId'] ?? '',
      username: json['username'] ?? '',
      userPhotoUrl: json['userPhotoUrl'] as String?,
      reason: json['reason'] as String?,
      userType: json['userType'] ?? '',
      reportedItemId: json['reportedItemId'] ?? '',
      reportDocid: json['reportDocid'] ?? '',
      postedDate: (json['postedDate'] as Timestamp).toDate(),
      reportDate:
          (json['reportDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
