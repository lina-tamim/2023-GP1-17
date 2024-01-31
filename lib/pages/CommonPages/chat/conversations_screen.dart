import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techxcel11/api/chat_api.dart';
import '../../../Models/chat.dart';
import '../../../Models/message_read_info.dart';
import '../../../utils/constants.dart';
import '../../../utils/functions/public_methods.dart';
import '../../../widgets/chat/chat_dashboard_tile.dart';
import '../../../widgets/misc_widgets.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Messages'),
          backgroundColor: primaryColor,
          toolbarHeight: 0,
        ),
        body: StreamBuilder<List<Chat>>(
          stream: ChatAPI().chats(),
          builder: (BuildContext context, AsyncSnapshot<List<Chat>> snapchat) {
            if (snapchat.hasError) {
              log('MK: error ${snapchat.error}');
              return Center(child: Text('Unable to load chats'));
            } else if (snapchat.hasData) {
              final List<Chat> chats = snapchat.data!
                  .where((Chat element) => element.deletedBy != getUid())
                  // .where((chatElement) =>
                  //     chatElement.lastMessage?.sendTo
                  //         .firstWhere(
                  //             (MessageReadInfo element) =>
                  //                 element.uid == getUid() &&
                  //                 (element.deliveryAt ?? 0) >=
                  //                     (chatElement.continueOn?[getUid()] ?? 0),
                  //             orElse: () =>
                  //                 MessageReadInfo(uid: '', seen: true))
                  //         .seen ==
                  //     false)
                  .toList();

              return Column(
                children: <Widget>[
                  Expanded(
                    child: chats.isEmpty
                        ? const Center(child: Text('No chats available'))
                        : ListView.separated(
                            itemCount: chats.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(
                              height: 1,
                              indent: 80,
                              color: Color(0xFFC7C4C4),
                            ),
                            itemBuilder: (BuildContext context, int index) =>
                                ChatDashboardTile(chat: chats[index]),
                          ),
                  ),
                ],
              );
            } else {
              return const AppLoadingWidget();
            }
          },
        ));
  }
}
