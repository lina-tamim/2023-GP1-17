class CardAnswer {
  int questionId;
  String userId;
  String answerText;
  int upvoteCount;
  String? username;
List<String>? upvotedUserIds;
  String? userPhotoUrl;
  final String docId;

  CardAnswer({
    required this.questionId,
    required this.userId,
    required this.answerText,
    required this.upvoteCount,
    required this.username,
    this.upvotedUserIds ,
    required this.userPhotoUrl,
    required this.docId ,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'userId': userId,
        'answerText': answerText,
        'upvoteCount': upvoteCount,
        'username': '',
        'upvotedUserIds': upvotedUserIds,
        'userPhotoUrl': userPhotoUrl,
        'docId':docId,
      };

  factory CardAnswer.fromJson(Map<String, dynamic> json) {
    return CardAnswer(
      questionId: json['questionId'] as int,
      userId: json['userId'] as String,
      answerText: json['answerText'] as String,
      upvoteCount: json['upvoteCount'] as int,
      username: json['username'] ?? '', // Parse the value as an int directly
      upvotedUserIds: List<String>.from(json['upvotedUserIds'] ?? []),
      userPhotoUrl: json['userPhotoUrl'] as String?,
       docId: json['docId'] ??'',

    );
  }
}
 