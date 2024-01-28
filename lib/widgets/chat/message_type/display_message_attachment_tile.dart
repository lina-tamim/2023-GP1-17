import 'package:flutter/material.dart';

import '../../../../Models/message_attachment.dart';
import '../../../pages/CommonPages/chat/message_attachment_screen.dart';
import '../../custom_network_image.dart';

class DisplayMessageAttachmentTile extends StatelessWidget {
  const DisplayMessageAttachmentTile({
    required this.attachments,
    required double borderRadius,
    required bool isMe,
    Key? key,
  })  : _isMe = isMe,
        _borderRadius = borderRadius,
        super(key: key);

  final bool _isMe;
  final double _borderRadius;
  final List<MessageAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 150,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: _isMe
              ? BorderRadius.only(
                  topRight: Radius.circular(_borderRadius),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                ),
          child: GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute<MessageAttachmentScreen>(
                    builder: (BuildContext context) => MessageAttachmentScreen(
                          attachments: attachments,
                        ))),
            child: attachments.length == 1
                ? _display(attachments[0])
                : Stack(
                    children: <Widget>[
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: _display(attachments[0]),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 0,
                        bottom: 0,
                        child: _display(attachments[1]),
                      ),
                      if (attachments.length > 2)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '${attachments.length - 2}+',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                  ),
                                ),
                                const Text(
                                  'Tap to view all',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  _display(MessageAttachment attachment) {
    return CustomNetworkImage(
      imageURL: attachment.url,
      fit: BoxFit.cover,
    );
  }
}
