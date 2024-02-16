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
      };

  factory CardAnswer.fromJson(Map<String, dynamic> json) {
    return CardAnswer(
      questionDocId: json['questionDocId'],
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

    );
  }
}
