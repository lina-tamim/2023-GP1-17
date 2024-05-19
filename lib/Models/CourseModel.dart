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
  String? docId;
  final String imageURL;
  final String? approval;
  final String? city;
  final String? country;
  final String? state;
  bool isRecommended;

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
    this.city,
    this.country,
    this.state,
    this.isRecommended = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      createdAt: json['createdAt'] is int
          ? Timestamp.fromMillisecondsSinceEpoch(json['createdAt']).toDate()
          : (json['createdAt'] as Timestamp).toDate(),
      description: json['description'],
      endDate: json['endDate'] == null
          ? null
          : json['endDate'] is int
              ? Timestamp.fromMillisecondsSinceEpoch(json['endDate']).toDate()
              : (json['endDate'] as Timestamp).toDate(),
      link: json['link'],
      location: json['location'],
      startDate: json['startDate'] == null
          ? null
          : json['startDate'] is int
              ? Timestamp.fromMillisecondsSinceEpoch(json['startDate']).toDate()
              : (json['startDate'] as Timestamp).toDate(),
      title: json['title'],
      type: json['type'],
      attendanceType: json['attendanceType'],
      userId: json['userEmail'],
      docId: json['docId'],
      imageURL: json['imageURL'],
      approval: json['approval'],
      city: json['city'],
      country: json['country'],
      state: json['state'],
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
      'approval': approval,
      'city': city,
      'country': country,
      'state': state,
    };
  }

  Map<String, dynamic> toJson2(String id) {
    return {
      'description': description,
      'endDate': endDate?.toIso8601String(),
      'location': location,
      'startDate': startDate?.toIso8601String(),
      'title': title,
      'my_id': id,
    };
  }
}
