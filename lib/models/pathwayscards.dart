import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PathwayContainer extends StatelessWidget {
  final int id; // Existing field for your custom ID
  final String imagePath;
  final String title;
  final String path_description;
  final List<String> Key_topic;
  final List<String> subtopics;
  final List<String> descriptions;
   final String? docId;


   PathwayContainer({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.path_description,
    required this.Key_topic,
    required this.subtopics,
    required this.descriptions,
     this.docId,
    //required this.resources, // Updated parameter
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'title': title,
        'path_description': path_description,
        'Key_topic': Key_topic,
        'subtopics': subtopics,
        'descriptions': descriptions,
        'docId':docId,
      };

  static PathwayContainer fromJson(Map<String, dynamic> json) =>
      PathwayContainer(
        id: json['id'], // Assuming 'id' is the field for your custom ID
        imagePath: json['image_url'],
        title: json['title'],
        path_description: json['path_description'],
        Key_topic: List<String>.from(json['Key_topic']),
        subtopics: List<String>.from(json['topics']),
        descriptions: List<String>.from(json['descriptions']),
        docId: json['docId'],
      );

  @override
  Widget build(BuildContext context) {
    // Use the docId as needed
    return Card();
  }
}