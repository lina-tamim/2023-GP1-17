class CardAview {
  int questionId;
  String userId;
  String answerText;
  int upvoteCount;
  String? username;
  List<String> upvotedUserIds;
  final String docId;
  String? userPhotoUrl; 
  


  CardAview(
      {
      required this.questionId,
      required this.userId,
      required this.answerText,
      required this.upvoteCount,
      this.upvotedUserIds = const [],
      required this.docId  ,
    required this.username,
    required this.userPhotoUrl,
      
      });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'userId': userId,
        'answerText': answerText,
        'upvoteCount': upvoteCount,
        'username': '',
        'upvotedUserIds': upvotedUserIds,
        'docId': docId,
         'userPhotoUrl': userPhotoUrl, 

      };

  factory CardAview.fromJson(Map<String, dynamic> json) {
    return CardAview(
        questionId: json['questionId'] as int,
        userId: json['userId'] as String,
        answerText: json['answerText'] as String,
        upvoteCount: json['upvoteCount'] as int,
        upvotedUserIds: List<String>.from(json['upvotedUserIds'] ?? []),
docId: json['docId'] ?? '',
        username: json['username'] ?? '',
                        userPhotoUrl: json['userPhotoUrl'] as String?, 
);
  }
}

 
