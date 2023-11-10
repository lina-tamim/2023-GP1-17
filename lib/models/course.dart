import 'package:cloud_firestore/cloud_firestore.dart';
class Course {
  final DateTime? createdAt;
  final String? description;
  final DateTime? endDate;
  final String? link;
  final String? location;
  final DateTime? startDate;
  final String? title;
  final String? type;
  final String? attendanceType;
  final String? userId;
  final String? docId;
  final String imageURL; // New attribute
  final String? approval;

  Course({
    this.createdAt,
    this.description,
    this.endDate,
    this.link,
    this.location,
    this.startDate,
    this.title,
    this.type,
    this.attendanceType,
    this.userId,
    this.docId,
    required this.imageURL,
    this.approval,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      createdAt: (json['created_at'] as Timestamp).toDate(),
      description: json['description'],
      endDate: json['end_date'] == null
          ? null
          : (json['end_date'] as Timestamp).toDate(),
      link: json['link'],
      location: json['location'],
      startDate: json['start_date'] == null
          ? null
          : (json['start_date'] as Timestamp).toDate(),
      title: json['title'],
      type: json['type'],
      attendanceType: json['attendanceType'],
      userId: json['userId'],
      docId: json['docId'],
      imageURL: json['imageURL'],
      approval: json['approval'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt?.toIso8601String(),
      'description': description,
      'end_date': endDate?.toIso8601String(),
      'link': link,
      'location': location,
      'start_date': startDate?.toIso8601String(),
      'title': title,
      'type': type,
      'attendanceType': attendanceType,
      'userId': userId,
      'docId': docId,
      'imageURL': imageURL,
      'approval':approval,
    };
  }
}
