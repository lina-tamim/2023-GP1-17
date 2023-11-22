import 'dart:ui';
//EDIT +CALNDER COMMIT

class EventModel {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
   String? docId;
  //final Color background; // New color property

  EventModel({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.location,
     this.docId,
    //required this.background, // New color property
  });
}