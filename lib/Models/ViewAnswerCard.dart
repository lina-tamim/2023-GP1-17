class CardAview {
  //String answerId;
  int questionId;
  String userId;
  String answerText;
  int upvoteCount;
  String? username;
  List<String> upvotedUserIds;
  final String docId;
  String? userPhotoUrl;
  String userType;

  CardAview({
    //required this.answerId,
    required this.questionId,
    required this.userId,
    required this.answerText,
    required this.upvoteCount,
    this.upvotedUserIds = const [],
    required this.docId,
    required this.username,
    required this.userPhotoUrl,
    required this.userType,
  });

  Map<String, dynamic> toJson() => {
        //'answerId': answerId,
        'questionId': questionId,
        'userId': userId,
        'answerText': answerText,
        'upvoteCount': upvoteCount,
        'username': '',
        'upvotedUserIds': upvotedUserIds,
        'docId': docId,
        'userPhotoUrl': userPhotoUrl,
        'userType': userType,
        // Update property name to userPhotoUrl
      };

  factory CardAview.fromJson(Map<String, dynamic> json) {
    return CardAview(
      //answerId: json['answerId'] as String,
      questionId: json['questionId'] as int,
      userId: json['userId'] as String,
      answerText: json['answerText'] as String,
      upvoteCount: json['upvoteCount'] as int,
      upvotedUserIds: List<String>.from(json['upvotedUserIds'] ?? []),
      docId: json['docId'],
      username: json['username'] ?? '',
      userPhotoUrl: json['userPhotoUrl'] as String?,
      userType: json['userType'] ?? '',
      // Update property name to userPhotoUrl
    );
  }
}
