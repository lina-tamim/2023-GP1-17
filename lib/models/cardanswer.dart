//Full code, m
class CardAnswer {
  String answerId;
  int questionId;
  String userId;
  String answerText;
  int upvoteCount;
  String? username;
  List<String> upvotedUserIds;
  String? userPhotoUrl;

  CardAnswer({
    required this.answerId,
    required this.questionId,
    required this.userId,
    required this.answerText,
    required this.upvoteCount,
    required this.username,
    this.upvotedUserIds = const [],
    required this.userPhotoUrl,
  });

  Map<String, dynamic> toJson() => {
        'answerId': answerId,
        'questionId': questionId,
        'userId': userId,
        'answerText': answerText,
        'upvoteCount': upvoteCount,
        'username': '',
        'upvotedUserIds': upvotedUserIds,
        'userPhotoUrl': userPhotoUrl,
      };

  factory CardAnswer.fromJson(Map<String, dynamic> json) {
    return CardAnswer(
      answerId: json['answerId'] as String,
      questionId: json['questionId'] as int,
      userId: json['userId'] as String,
      answerText: json['answerText'] as String,
      upvoteCount: json['upvoteCount'] as int,
      username: json['username'] ?? '', // Parse the value as an int directly
      upvotedUserIds: List<String>.from(json['upvotedUserIds'] ?? []),
      userPhotoUrl: json['userPhotoUrl'] as String?,
    );
  }
}


//TECHXCEL