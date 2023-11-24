import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CourseAndEventImagePicker extends StatefulWidget {
const CourseAndEventImagePicker({Key? key, required this.onPickImage})
      : super(key: key);

  final void Function(File pickedImage) onPickImage;

  @override
  State<CourseAndEventImagePicker> createState() {
    return _CourseAndEventImagePickerState();
  }
}

class _CourseAndEventImagePickerState extends State<CourseAndEventImagePicker> {
  File? _pickedImageFile;
  final String defaultPhotoUrl =
      'assets/Backgrounds/defaultCoursePic.png';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 70,
          backgroundImage: AssetImage(defaultPhotoUrl) as ImageProvider<Object>,
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.add_a_photo),
          label: const Text(
            "Add image",
            style: TextStyle(color: Colors.black),
          ),
        )
      ],
    );
  }
}
