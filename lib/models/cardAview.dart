class CardAview {
  String answerId;
  int questionId;
  String userId;
  String answerText;
  int upvoteCount;
  String username;
  List<String> upvotedUserIds;
  final String docId;

  CardAview(
      {required this.answerId,
      required this.questionId,
      required this.userId,
      required this.answerText,
      required this.upvoteCount,
      required this.username,
      this.upvotedUserIds = const [],
      required this.docId});

  Map<String, dynamic> toJson() => {
        'answerId': answerId,
        'questionId': questionId,
        'userId': userId,
        'answerText': answerText,
        'upvoteCount': upvoteCount,
        'username': '',
        'upvotedUserIds': upvotedUserIds,
        'docId': docId
      };

  factory CardAview.fromJson(Map<String, dynamic> json) {
    return CardAview(
        answerId: json['answerId'] as String,
        questionId: json['questionId'] as int,
        userId: json['userId'] as String,
        answerText: json['answerText'] as String,
        upvoteCount: json['upvoteCount'] as int,
        username: json['username'] ?? '', // Parse the value as an int directly
        upvotedUserIds: List<String>.from(json['upvotedUserIds'] ?? []),
        docId: json['docId']);
  }
}

//TECHXCEL

