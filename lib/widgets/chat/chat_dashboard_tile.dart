// ignore_for_file: no_leading_underscores_for_local_identifiers, unnecessary_nullable_for_final_variable_declarations

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../Models/chat.dart';
import '../../Models/message.dart';
import '../../Models/message_attachment.dart';
import '../../Models/message_read_info.dart';
import '../../Models/user.dart';
import '../../pages/CommonPages/chat/chat_screen.dart';
import '../../providers/profile_provider.dart';
import '../../utils/app_images.dart';
import '../../utils/functions/public_methods.dart';
import '../../utils/functions/time_functions.dart';
import '../../utils/message_type_enum.dart';

class ChatDashboardTile extends StatelessWidget {
  const ChatDashboardTile({required this.chat, Key? key}) : super(key: key);
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(builder: (
      BuildContext context,
      ProfileProvider userPro,
      _,
    ) {
      return FutureBuilder<User?>(
        future: userPro.searchUser(
            uid: chat.persons
                .firstWhereOrNull((String element) => element != getUid())),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          final User? _user = snapshot.data;
          if (snapshot.hasError) {
            return Container();
          }
          final String? image = _user?.profileUrl;
          final String name = _user?.name ?? 'Anonymous';
          final Message? _msg = chat.lastMessage;

          chat.name = name;
          chat.imageURL = image;

          final String? _subtitle = messageHint(
            chat.lastMessage ??
                Message(
                    messageID: '',
                    text: '',
                    type: MessageTypeEnum.text,
                    attachment: <MessageAttachment>[],
                    sendBy: '',
                    sendTo: <MessageReadInfo>[],
                    timestamp: 0),
          );
          return InkWell(
            // tileColor: Theme.of(context).cardColor,
            // dense: true,
            onTap: () {
              if (_user == null) {
                showToast('Unable to open this chat. User no longer exists');
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute<ChatScreen>(
                  builder: (BuildContext context) =>
                      ChatScreen(chat: chat, chatWith: _user),
                ),
              );
            },
            child: Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _CircularImage(imageURL: image, radius: 26),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: <Widget>[
                              if (chat.lastMessage != null &&
                                  chat.lastMessage!.sendTo.isNotEmpty &&
                                  chat.lastMessage!.sendBy == getUid())
                                SizedBox(
                                  height: 8,
                                  child: Image.asset(
                                    chat.lastMessage?.sendTo[0].seen ?? false
                                        ? AppImages.doubleTickBlue
                                        : AppImages.doubleTickGrey,
                                  ),
                                ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _subtitle ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        TimeFunctions.timeInWords(_msg?.timestamp ?? 0),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      ((chat.lastMessage?.sendBy ?? '') != getUid() &&
                              (chat.unseenMessages.isNotEmpty))
                          ? CircleAvatar(
                              radius: 10,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: FittedBox(
                                  child: Text(
                                    numberOfMessages(chat),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                          : chat.isUnredByMe
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 02),
                                  child: CircleAvatar(
                                    radius: 5,
                                    backgroundColor: Colors.red,
                                  ),
                                )
                              : const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  String messageHint(Message lastMessage) {
    if (lastMessage.text != null && (lastMessage.text?.isNotEmpty ?? false)) {
      return lastMessage.text ?? '';
    } else if (lastMessage.attachment.isNotEmpty) {
      final MessageTypeEnum _tempType = lastMessage.type;
      if (_tempType == MessageTypeEnum.text) {
        return 'Text message';
      }
      if (_tempType == MessageTypeEnum.image) {
        return '📸 photo';
      } else {
        return 'Check the message...';
      }
    } else {
      return 'Check the message...';
    }
  }
}

class _CircularImage extends StatelessWidget {
  const _CircularImage({
    required this.imageURL,
    required this.radius,
    Key? key,
  }) : super(key: key);
  final double radius;
  final String? imageURL;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: imageURL == null || (imageURL?.isEmpty ?? false)
          ? CircleAvatar(
              radius: radius - 1,
              backgroundColor: Theme.of(context).shadowColor,
              child: CircleAvatar(
                radius: radius - 2,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: Icon(Icons.person, size: radius),
              ),
            )
          : CachedNetworkImage(
              imageUrl: imageURL!,
              fit: BoxFit.cover,
              imageBuilder: (
                BuildContext context,
                ImageProvider<Object> imageProvider,
              ) {
                return CircleAvatar(
                  radius: radius,
                  backgroundImage: imageProvider,
                );
              },
              progressIndicatorBuilder: (BuildContext context, String url,
                      DownloadProgress downloadProgress) =>
                  Center(
                      child: Text(
                'loading...  ${downloadProgress.progress?.toStringAsFixed(1) ?? ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              )),
              errorWidget: (BuildContext context, String url, dynamic _) =>
                  const Icon(Icons.error, color: Colors.grey),
            ),
    );
  }
}
