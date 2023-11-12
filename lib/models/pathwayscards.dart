import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PathwayContainer extends StatelessWidget {
  final String imagePath;
  final String title;
  final String path_description;
  final List<String> Key_topic;
  final List<String> subtopics;
  final List<String> descriptions;

  const PathwayContainer({
    required this.imagePath,
    required this.title,
    required this.path_description,
    required this.Key_topic,
    required this.subtopics,
    required this.descriptions,
    //required this.resources, // Updated parameter
  });

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'title': title,
        'path_description': path_description,
        'Key_topic': Key_topic,
        'subtopics': subtopics,
        'descriptions': descriptions,
        /*'resources': resources
            .map((list) => list.map((controller) => controller.text).toList())
            .toList(),*/
      };

  static PathwayContainer fromJson(Map<String, dynamic> json) =>
      PathwayContainer(
        imagePath: json['image_url'],
        title: json['title'],
        path_description: json['path_description'],
        Key_topic: List<String>.from(json['Key_topic']),
        subtopics: List<String>.from(json['topics']),
        descriptions: List<String>.from(json['descriptions']),
        /*resources: List<List<TextEditingController>>.from(
          json['resources'].map(
            (list) => List<TextEditingController>.from(
              list.map(
                (controllerJson) => TextEditingController.fromValue(
                  TextEditingValue.fromJSON(controllerJson),
                ),
              ),
            ),
          ),
        ),*/
      );

  @override
  Widget build(BuildContext context) {
    return Card();
  }
}