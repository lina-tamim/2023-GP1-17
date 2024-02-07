class CardAnswer {
  //String answerId;
  int questionId;
  String userId;
  String answerText;
  int upvoteCount;
  String? username;
  List<String> upvotedUserIds;
  String docId;
  String? userPhotoUrl;
  String? reason;
  String userType;

  CardAnswer({
    //required this.answerId,
    required this.questionId,
    required this.userId,
    required this.answerText,
    required this.upvoteCount,
    this.upvotedUserIds = const [],
    this.docId = '',
    required this.username,
    required this.userPhotoUrl,
    this.reason,
    required this.userType,
  });

  Map<String, dynamic> toJson() => {
        //'answerId': answerId,
        'questionId': questionId,
        'userId': userId,
        'answerText': answerText,
        'upvoteCount': upvoteCount,
        'username': username,
        'upvotedUserIds': upvotedUserIds,
        'docId': docId,
        'userPhotoUrl': userPhotoUrl,
        'reason': reason,
        'userType': userType,
      };

  factory CardAnswer.fromJson(Map<String, dynamic> json) {
    return CardAnswer(
      //answerId: json['answerId'] as String,
      questionId: json['questionId'] as int,
      userId: json['userId'] as String,
      answerText: json['answerText'] as String,
      upvoteCount: json['upvoteCount'] as int,
      upvotedUserIds: List<String>.from(json['upvotedUserIds'] ?? []),
      docId: json['docId'] ?? '',
      username: json['username'] ?? '',
      userPhotoUrl: json['userPhotoUrl'] as String?,
      reason: json['reason'] as String?,
      userType: json['userType'] ?? '',

// Update property name to userPhotoUrl
    );
  }
}
