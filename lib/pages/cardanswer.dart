class CardAnswer {
  String answerId;
  int questionId;
  String userId;
  String docId;
  String answerText;
  int upvoteCount;

  CardAnswer({
    required this.answerId,
    required this.questionId,
    required this.userId,
    required this.docId,
    required this.answerText,
    required this.upvoteCount,
  });

  Map<String, dynamic> toJson() => {
        'answerId': answerId,
        'questionId': questionId,
        'userId': userId,
        'docId': docId,
        'answerText': answerText,
        'upvoteCount': upvoteCount,
      };

  factory CardAnswer.fromJson(Map<String, dynamic> json) {
    return CardAnswer(
      answerId: json['answerId'] as String,
      questionId: json['questionId'] as int,
      userId: json['userId'] as String,
      docId: json['docId'] ?? '',
      answerText: json['answerText'] as String,
      upvoteCount:
          json['upvoteCount'] as int, // Parse the value as an int directly
    );
  }
}
