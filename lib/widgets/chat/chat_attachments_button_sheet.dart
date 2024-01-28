import 'dart:io';

// import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Models/chat.dart';
import '../../utils/functions/file_picker_functions.dart';
import '../../utils/message_type_enum.dart';
import 'chat_icon_button.dart';

class ChatAttachmentsButtonsSheet extends StatelessWidget {
  const ChatAttachmentsButtonsSheet({
    required this.chat,
    required this.onFilePicker,
    Key? key,
  }) : super(key: key);
  final Chat chat;
  final void Function(List<File> file, MessageTypeEnum type) onFilePicker;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 8),
        const SizedBox(
          width: 100,
          height: 4,
          child: Divider(thickness: 4),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                ChatIconButton(
                  bgColor: const Color.fromRGBO(13, 71, 161, 1),
                  icon: CupertinoIcons.camera_fill,
                  iconColor: Colors.white60,
                  title: 'Camera',
                  onTap: () async {
                    final XFile? file = await FilePickerFunctions().camera();
                    if (file == null) return;
                    onFilePicker(
                        <File>[File(file.path)], MessageTypeEnum.image);
                  },
                ),
              ],
            ),
            Column(
              children: <Widget>[
                ChatIconButton(
                  bgColor: Colors.deepPurpleAccent,
                  icon: CupertinoIcons.photo,
                  iconColor: Colors.white60,
                  title: 'Gallery',
                  onTap: () async {
                    final List<File> files = await FilePickerFunctions()
                        .filePicker(type: FileType.image);
                    onFilePicker(files, MessageTypeEnum.image);
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
