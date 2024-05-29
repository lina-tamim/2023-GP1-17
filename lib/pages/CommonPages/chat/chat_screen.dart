import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:techxcel11/utils/constants.dart';
import '../../../Models/chat.dart';
import '../../../Models/message.dart';
import '../../../Models/message_read_info.dart';
import '../../../Models/user.dart';
import '../../../api/chat_api.dart';
import '../../../utils/functions/public_methods.dart';
import '../../../utils/functions/time_functions.dart';
import '../../../widgets/chat/chat_text_field.dart';
import '../../../widgets/chat/message_type/message_tile.dart';
import '../../../widgets/misc_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.chat,
    this.chatWith,
    Key? key,
  }) : super(key: key);
  final Chat chat;
  final User? chatWith;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  // final AutoScrollController  _scrollController = AutoScrollController();
  scrollingDown() async {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final chat = await ChatAPI().getSingleChat(widget.chat.chatID);
      setState(() {
        selfId = getUid();
        widget.chat.deletedBy = chat?.deletedBy;
        widget.chat.continueOn = chat?.continueOn;
        // loading = true;
      });
      // myName();
    });
    super.initState();
  }

  String? selfId;
  bool loading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(37, 6, 81, 0.898),
        foregroundColor: Colors.white,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                  ),
                ),
              ],
            ),
            // if (widget.chatWith.profileImage != null &&
            //     widget.chatWith.profileImage != '')
            RoundedNetworkAvatar(
              url: widget.chatWith?.profileUrl,
              color: accentColor,
              height: 34,
              width: 34,
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                widget.chatWith?.name ?? 'ymous',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        leadingWidth: 0,
        actions: [
          if (widget.chat.deletedBy != selfId)
            IconButton(
                onPressed: () {
                  showDeleteDialog();
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                ))
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: ChatAPI().messages(widget.chat.chatID,
                  showAfterTimestamp: widget.chat.continueOn?[getUid()]),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Message>> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Facing some error'));
                } else if (snapshot.hasData) {
                  final List<Message> messages = snapshot.data!;
                  if (messages.length > 1 && messages.last.sendTo.first.seen) {
                    widget.chat.unseenMessages.clear();
                  }
                  return messages.isEmpty
                      ? SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              Text(
                                'Send a message!',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'and start conversation',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : _MessageLists(
                          messages: messages,
                          chat: widget.chat,
                          loading: loading,
                          scrollController: _scrollController,
                          scrollDown: scrollingDown,
                        );
                } else {
                  return AppLoadingWidget();
                }
              },
            ),
          ),
          ChatTextField(
            chat: widget.chat,
            scrollDown: scrollingDown,
            stateRefresher: () {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  showDeleteDialog() {
    bool loading = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(loading ? 'Deleting Chat...' : 'Confirm Deletion'),
            content: loading
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(child: CircularProgressIndicator()),
                    ],
                  )
                : Text(
                    'Are you sure you want to delete this Chat? All messages will be deleted for you.'),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  // await Future.delayed(Duration(seconds: 3));
                  await ChatAPI().deleteChat(widget.chat.chatID);
                  setState(() {
                    loading = false;
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }
}

class _MessageLists extends StatefulWidget {
  const _MessageLists({
    required this.messages,
    required this.chat,
    required this.scrollController,
    required this.scrollDown,
    this.loading = false,
    Key? key,
  }) : super(key: key);
  final ScrollController scrollController;
  final List<Message> messages;
  final Chat chat;

  final dynamic scrollDown;
  final bool loading;

  @override
  State<_MessageLists> createState() => _MessageListsState();
}

class _MessageListsState extends State<_MessageLists> {
  String? selfId;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) async {
      setState(() {
        selfId = getUid();
      });
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      widget.scrollDown();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      constraints: const BoxConstraints(
        minWidth: 50,
      ),
      child: GroupedListView<Message, String>(
        controller: widget.scrollController,
        shrinkWrap: true,
        reverse: true,
        order: GroupedListOrder.ASC,
        useStickyGroupSeparators: true,
        elements: widget.messages,
        groupBy: (Message message) =>
            DateTime.fromMicrosecondsSinceEpoch(message.timestamp)
                .toString()
                .substring(0, 10),
        groupComparator: (String group1, String group2) =>
            DateTime.parse(group2).compareTo(DateTime.parse(group1)),
        itemComparator: (Message item2, Message item1) =>
            item1.timestamp.compareTo(item2.timestamp),
        stickyHeaderBackgroundColor: Colors.transparent,
        groupHeaderBuilder: (Message element) {
          return Container(
            // color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  constraints: const BoxConstraints(minWidth: 50),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    TimeFunctions.chatMessageDate(element.timestamp),
                    style: const TextStyle(color: Colors.black, fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        },
        itemBuilder: (BuildContext context, Message msg) {
          if (msg.sendBy != selfId && msg.sendTo[0].seen == false) {
            updateMessage(widget.chat, msg, true);
          }
          return MessageTile(
            message: msg,
            loading: widget.loading,
            key: ValueKey<String>(msg.messageID),
          );
        },
      ),
    );
  }

  updateMessage(Chat chat, Message message, bool isLast) async {
    final String? me = selfId;
    if (me == null) return;
    if (message.sendBy == me) return;
    final int time = TimeFunctions.microseconds;
    MessageReadInfo info = MessageReadInfo(
      uid: me,
      delivered: true,
      deliveryAt: time,
      seen: true,
      seenAt: time,
    );
    if (message.sendTo.isEmpty) {
      message.sendTo.add(info);
    } else {
      if (message.sendTo[0].seen == true) return;
      message.sendTo[0].seen = true;
      message.sendTo[0].seenAt = TimeFunctions.microseconds;
    }
    if (isLast) {
      chat.unseenMessages = <Message>[];
      if (chat.lastMessage != null) {
        if (chat.lastMessage!.sendTo.isEmpty) {
          chat.lastMessage!.sendTo.add(info);
        } else {
          chat.lastMessage!.sendTo[0].seen = true;
        }
      }
    }
    await ChatAPI().updateMessage(chat: chat, msg: message, isLast: isLast);
  }
}
