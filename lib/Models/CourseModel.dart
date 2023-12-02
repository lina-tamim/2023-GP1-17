import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final DateTime? createdAt;
  final String? description;
  final DateTime? endDate;
  final String? link;
  final String location;
  final DateTime? startDate;
  final String? title;
  final String? type;
  final String? attendanceType;
  final String? userId;
  final String? docId;
  final String imageURL;
  final String? approval;

  Course({
    this.createdAt,
    this.description,
    this.endDate,
    this.link,
    required this.location,
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
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      description: json['description'],
      endDate: json['endDate'] == null
          ? null
          : (json['endDate'] as Timestamp).toDate(),
      link: json['link'],
      location: json['location'],
      startDate: json['startDate'] == null
          ? null
          : (json['startDate'] as Timestamp).toDate(),
      title: json['title'],
      type: json['type'],
      attendanceType: json['attendanceType'],
      userId: json['userEmail'],
      docId: json['docId'],
      imageURL: json['imageURL'],
      approval: json['approval'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt?.toIso8601String(),
      'description': description,
      'endDate': endDate?.toIso8601String(),
      'link': link,
      'location': location,
      'startDate': startDate?.toIso8601String(),
      'title': title,
      'type': type,
      'attendanceType': attendanceType,
      'userEmail': userId,
      'docId': docId,
      'imageURL': imageURL,
      'approval':approval,
    };
  }

  Map<String, dynamic> toJson2(String id) {
    return {
      'description': description,
      'endDate': endDate?.toIso8601String(),
      //'link': link,
      'location': location,
      'startDate': startDate?.toIso8601String(),
      'title': title,
      //'type': type,
      //'attendanceType': attendanceType,
      //'docId': docId,
      //'imageURL': imageURL,
      'my_id':id,
    };
  }
}
 