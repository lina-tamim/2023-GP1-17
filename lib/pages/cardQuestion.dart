import 'dart:core';
class CardQuestion {
  final int id;
  final String postType;
  final String title;
  final String description;
  final List<String> topics;
  final String userId;
  //final int anwersNo;

  CardQuestion({
    required this.id,
    required this.postType,
    required this.title,
    required this.description,
    required this.topics,
    required this.userId,
    //required this.anwersNo,
  });
Map<String, dynamic> toJson() =>{
     'id':id,
      'dropdownValue': postType,
      'textFieldValue': title,
      'largeTextFieldValue': description,
      'selectedInterests': topics,
      'userId':userId,
      //'anwersNo':anwersNo,
};
  

static CardQuestion fromJson(Map<String, dynamic> json) => CardQuestion(
  id:json['id'],
  postType: json['dropdownValue'],
  title: json['textFieldValue'],
  description: json['largeTextFieldValue'],
  topics:List<String>.from(json['selectedInterests']),
  userId:json['userId'],
 //anwersNo:json['anwersNo']
 );

}