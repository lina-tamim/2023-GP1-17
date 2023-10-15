// this class is used to handle all flutter - firebase activities 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techxcel11/UserModel.dart';

class UserRepository extends GetxController {
static UserRepository get instance => Get.find();

final _db = FirebaseFirestore.instance;

// ADD USER
createUser( UserModel user) async
{
  await _db.collection('users').add(user.toJson())
  .whenComplete(
    () => Get.snackbar("Success", "Your account has been successfully created.",
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green,
    colorText: Colors.amber),
  )
  .catchError((error, stackTrace) {
Get.snackbar("Error", "Something went wrong. Try again",
snackPosition: SnackPosition.BOTTOM,
backgroundColor: Colors.redAccent.withOpacity(0.1),
    colorText: Colors.amber);
    print(error.toString());
  });
}











}//end class


//Store user in FireStore
/*
Future<void> createUser(UserModel user) async{

}

// Fetch All users or user details
Future<UserModel> getUserDetails(String email) async{
final snapshot = await _db.collection('users').where("Email", isEqualTo: email).get();
final userData = snapshot.docs.map((e)=> UserModel.fromSnapshot(e)).single;
return userData;


}*/

















