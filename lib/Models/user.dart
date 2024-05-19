import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/functions/public_methods.dart';

class User {
  String? uid;
  String? name;
  String? profileUrl;
  String? email;

  User({
    this.uid,
    this.name,
    this.profileUrl,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json, String id) {
    return User(
      uid: id,
      name: json['username'],
      profileUrl: json['imageURL'],
      email: json['email'],
    );
  }
}
