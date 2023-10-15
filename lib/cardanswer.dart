
import 'package:cloud_firestore/cloud_firestore.dart';

class CardAnswer {
  int answerId;
  int questionId;
  String userId;
  String answerText;
  //final DateTime timestamp;
  int upvoteCount;

  CardAnswer({
    required this.answerId,
    required this.questionId,
    required this.userId,
    required this.answerText,
    required this.upvoteCount,
    //required this.timestamp,
  });

  Map<String, dynamic> toJson() =>{

      'answerId': answerId,
      'questionId': questionId,
      'userId': userId,
      'answerText':answerText,
      'upvoteCount': upvoteCount,
      //'timestamp':timestamp,
};
  

static CardAnswer fromJson(Map<String, dynamic> json) => CardAnswer(
  answerId: json['answerId'],
  questionId: json['questionId'],
  userId: json['userId'],
  
  answerText:json['answerText'],
  upvoteCount:json['upvoteCount'],
  //timestamp: (json['timestamp'] as Timestamp).toDate(), 
  );
}