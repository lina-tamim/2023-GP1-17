import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class UserEditImagePicker extends StatefulWidget {
  const UserEditImagePicker({Key? key, required this.onPickImage})
      : super(key: key);

  final void Function(File pickedImage) onPickImage;

  @override
  State<UserEditImagePicker> createState() {
    return _UserEditImagePickerState();
  }
}

class _UserEditImagePickerState extends State<UserEditImagePicker> {
  File? _pickedImageFile;
  bool _isLoading = false;
  String loggedInimageUrl = '';
  String defaultPhotoUrl = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickImage(_pickedImageFile!);
  }

  Future<void> fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs[0].data();
      final imageUrl = userData['imageUrl'] ?? '';

      setState(() {
        loggedInimageUrl = imageUrl;
        defaultPhotoUrl = imageUrl;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: defaultPhotoUrl.isNotEmpty
              ? NetworkImage(defaultPhotoUrl)
      : AssetImage('assets/Backgrounds/defaultUserPic.png') as ImageProvider<Object>, // Cast to ImageProvider<Object>
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.add_a_photo, size: 16,),
          label: const Text(
            "Change your profile picture",
            style: TextStyle(color: Colors.black, fontSize: 9),
          ),
        )
      ],
    );
  }
}