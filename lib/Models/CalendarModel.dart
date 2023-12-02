class EventModel {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  String? docId;

  EventModel({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.location,
     this.docId,
  });
}
 