import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Models/message.dart';
import '../../../utils/functions/public_methods.dart';
import '../../../utils/message_type_enum.dart';
import '../../custom_network_image.dart';
import 'chat_time_widget.dart';
import 'display_message_attachment_tile.dart';

import 'package:techxcel11/utils/constants.dart';

class MessageTile extends StatelessWidget {
  const MessageTile({required this.message, Key? key, this.loading = false})
      : super(key: key);
  final Message message;
  final bool loading;

  static const double _borderRadius = 12;
  openURL(String value) async {
    final Uri url = Uri.parse(value);
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.sendBy == getUid();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(_borderRadius),
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_borderRadius),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(1, 1),
                  ),
                ],
                color: isMe
                    ? primaryColor //#DEF1FD
                    : Colors.grey,
              ),
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (message.attachment.isNotEmpty)
                        DisplayMessageAttachmentTile(
                          isMe: isMe,
                          borderRadius: _borderRadius,
                          attachments: message.attachment,
                        ),
                      if (message.text != null && message.text!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.70,
                              minWidth: 150,
                            ),
                            child: SelectableText(
                              message.text ?? 'no message',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: isMe || true
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ChatTimeWidget(message: message, isMe: isMe),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
