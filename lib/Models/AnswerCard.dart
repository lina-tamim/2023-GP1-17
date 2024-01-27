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
        'userPhotoUrl': userPhotoUrl, // Update property name to userPhotoUrl
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
      userPhotoUrl: json['userPhotoUrl']
          as String?, // Update property name to userPhotoUrl
    );
  }
}
