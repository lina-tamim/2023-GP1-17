import 'dart:core';

class CardQview {
  final int id;
  //final String postType;
  final String title;
  final String description;
  final List<String> topics;
  final String userId;
  String? docId;
  String? username;
  String? userPhotoUrl; 

  CardQview({
    required this.id,
    //required this.postType,
    required this.title,
    required this.description,
    required this.topics,
    required this.userId,
    this.docId ='' ,
    required this.username,
    required this.userPhotoUrl,
  });

  Map<String, dynamic> toJson() => {
        'questionCount': id,
        //'dropdownValue': postType,
        'postTitle': title,
        'postDescription': description,
        'selectedInterests': topics,
        'userId': userId,
        'docId': docId,
        'username': username,
        'userPhotoUrl': userPhotoUrl, 
      };

  static CardQview fromJson(Map<String, dynamic> json) => CardQview(
        id: json['questionCount'],
        //postType: json['dropdownValue'],
        title: json['postTitle'],
        description: json['postDescription'],
        topics: List<String>.from(json['selectedInterests']),
        userId: json['userId'],
        docId: json['docId'] ?? '',
        username: json['username'] ?? '',
        userPhotoUrl: json['userPhotoUrl'] as String?, 
      );
}

