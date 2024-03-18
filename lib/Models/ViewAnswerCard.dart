import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardAview {
  String questionDocId;
  String userId;
  String answerText;
  int upvoteCount;
  String? username;
  List<String> upvotedUserIds;
  final String docId;
  String? userPhotoUrl;
  String userType;
  DateTime postedDate;

  CardAview({
    required this.questionDocId,
    required this.userId,
    required this.answerText,
    required this.upvoteCount,
    this.upvotedUserIds = const [],
    required this.docId,
    required this.username,
    required this.userPhotoUrl,
    required this.userType,
    required this.postedDate,
  });

  Map<String, dynamic> toJson() => {
        'questionDocId': questionDocId,
        'userId': userId,
        'answerText': answerText,
        'upvoteCount': upvoteCount,
        'username': '',
        'upvotedUserIds': upvotedUserIds,
        'docId': docId,
        'userPhotoUrl': userPhotoUrl,
        'userType': userType,
        'postedDate': Timestamp.fromDate(postedDate),
      };

  factory CardAview.fromJson(Map<String, dynamic> json) {
    log('MK: json: ${json}');
    return CardAview(
      questionDocId: json['questionDocId'] ?? json['questionId'],
      userId: json['userId'] as String,
      answerText: json['answerText'] as String,
      upvoteCount: json['upvoteCount'] as int,
      upvotedUserIds: List<String>.from(json['upvotedUserIds'] ?? []),
      docId: json['docId'],
      username: json['username'] ?? '',
      userPhotoUrl: json['userPhotoUrl'] as String?,
      userType: json['userType'] ?? '',
      postedDate: (json['postedDate'] as Timestamp).toDate(),
    );
  }
}
