import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PathwayContainer extends StatelessWidget {
  final int id;
  final String imagePath;
  final String title;
  final String path_description;
  final List<String> Key_topic;
  final List<String> subtopics;
  final List<String> descriptions;
  final List<String> resources;
 final String pathwayDocId;
 String? docIdSearch;

  PathwayContainer({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.path_description,
    required this.Key_topic,
    required this.subtopics,
    required this.descriptions,
    required this.resources,
    required this.pathwayDocId,
    this.docIdSearch,
  });

  // Additional constructor to create a PathwayContainer with a docId
  PathwayContainer.withDocId({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.path_description,
    required this.Key_topic,
    required this.subtopics,
    required this.descriptions,
    required this.resources,
    required this.pathwayDocId ,
    this.docIdSearch,
  }) ;

  Map<String, dynamic> toJson() => {
        'pathwayNo': id,
        'imageURL': imagePath,
        'title': title,
        'pathwayDescription': path_description,
        'keyTopic': Key_topic,
        'subtopics': subtopics,
        'descriptions': descriptions,
        'resources': resources,
        'pathwayDocId': pathwayDocId, // Include docId in the JSON representation
        'docIdSearch':docIdSearch,
      };

  static PathwayContainer fromJson(Map<String, dynamic> json) =>
      PathwayContainer(
        id: json['pathwayNo'] ?? 0,
        imagePath: json['imageURL'] ?? '',
        title: json['title'] ?? '',
        path_description: json['pathwayDescription'] ?? '',
        Key_topic: List<String>.from(json['keyTopic'] ?? []),
        subtopics: List<String>.from(json['subtopics'] ?? []),
        descriptions: List<String>.from(json['descriptions'] ?? []),
        resources: List<String>.from(json['resources'] ?? []),
        pathwayDocId: json['pathwayDocId'],
        docIdSearch:json['pathwayDocId'],
      );

  @override
  Widget build(BuildContext context) {
    return Card();
  }
}
