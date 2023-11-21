import 'package:flutter/material.dart';

///RESOURCES 
///
///
class ResourceContainer extends StatelessWidget{

final int subtopic_id;
final String pathway_id;
final List<String> link;


  const ResourceContainer({
    required this.subtopic_id,
    required this.pathway_id,
    required this.link,
  });

    Map<String, dynamic> toJson() => {
        'subtopic_id': subtopic_id,
        'pathway_id': pathway_id,
        'link': link,
       
      };

  static ResourceContainer fromJson(Map<String, dynamic> json) =>
      ResourceContainer(
        subtopic_id: json['subtopic_id'],
        pathway_id: json['pathway_id'],
        link: List<String>.from(json['link']),
      
      );


       @override
  Widget build(BuildContext context) {
    return Card();
  }
}