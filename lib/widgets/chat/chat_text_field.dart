import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../../api/chat_api.dart';
import '../../../Models/chat.dart';
import '../../../Models/message.dart';
import '../../../Models/message_attachment.dart';
import '../../../Models/message_read_info.dart';
import '../../Models/ReusedElements.dart';
import '../../utils/constants.dart';
import '../../utils/functions/public_methods.dart';
import '../../utils/functions/time_functions.dart';
import '../../utils/message_type_enum.dart';
import 'chat_attachments_button_sheet.dart';

class ChatTextField extends StatefulWidget {
  const ChatTextField({
    required this.chat,
    required this.scrollDown,
    Key? key,
    // required this.chatWith,
  }) : super(key: key);
  final Chat chat;
  final dynamic scrollDown;

  // final User chatWith;

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  final TextEditingController _text = TextEditingController();

  // final FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  List<File> files = <File>[];
  static const double borderRadius = 12;
  bool isRecoderInit = false;
  bool isRecording = false;
  bool isLoading = false;
  bool disableText = false;
  String audioFilePath = '/flutter_sound.aac';
  MessageTypeEnum types = MessageTypeEnum.text;

  void _onListen() => setState(() {});

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  void initState() {
    // openAudio();
    _text.addListener(_onListen);
    super.initState();
  }

  @override
  void dispose() {
    _text.dispose();
    _text.removeListener(_onListen);
    // _soundRecorder.closeRecorder();
    isRecoderInit = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // const SizedBox(height: 0),
        if (files.isNotEmpty)
          Container(
            height: 90,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            decoration: BoxDecoration(
              // color: accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: files.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          child: SizedBox(
                              height: 80,
                              width: 80,
                              child:
                                  Image.file(files[index], fit: BoxFit.cover)),
                        );
                      },
                    ),
                  ),
                ),
                isLoading
                    ? const Text('Sending...')
                    : SizedBox(
                        width: 50,
                        height: 80,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              files.clear();
                              disableText = false;
                            });
                          },
                          splashRadius: 16,
                          icon: const Icon(Icons.cancel),
                        ),
                      )
              ],
            ),
          ),
        if ((!isLoading || files.isEmpty))
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    decoration: BoxDecoration(
                        border: Border.all(color: primaryColor),
                        borderRadius:
                            BorderRadius.circular(getWidth(context) * 0.09)),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            types = MessageTypeEnum.image;
                            await showModalBottomSheet(
                              context: context,
                              isDismissible: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              builder: (BuildContext context) =>
                                  ChatAttachmentsButtonsSheet(
                                chat: widget.chat,
                                onFilePicker:
                                    (List<File> file, MessageTypeEnum type) {
                                  setState(() {
                                    types = type;
                                    files = file;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                          child: Container(
                            width: getWidth(context) * 0.07,
                            height: getWidth(context) * 0.07,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF000000),
                                ),
                                shape: BoxShape.circle),
                            child: const Center(
                              child: Icon(
                                Icons.attach_file,
                                color: primaryColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: getHeight(context) * 0.027,
                          child: const VerticalDivider(
                            thickness: 1.5,
                            color: Color(0xFF131250),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            // enabled: true,
                            readOnly: disableText,
                            controller: _text,
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            minLines: 1,
                            decoration: const InputDecoration(
                                hintText: 'Write a message...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                // filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: getWidth(context) * 0.02,
                ),
                // if(_text.text.isNotEmpty || files.isNotEmpty)
                InkWell(
                  onTap: () async {
                    if ((_text.text.trim().isEmpty && files.isEmpty) ||
                        isLoading) {
                      return;
                    }
                    final String? meUID = getUid();
                    if (meUID == null) return;
                    setState(() {
                      isLoading = true;
                    });
                    final Chat? receiver = widget.chat;
                    if (receiver == null) {
                      toastMessage('Check your internet Connection');
                      return;
                    }
                    final int time = TimeFunctions.microseconds;
                    List<MessageAttachment> attachments = <MessageAttachment>[];
                    if (files.isNotEmpty) {
                      for (File element in files) {
                        final String? url = await ChatAPI().uploadAttachment(
                          file: element,
                          chatID: widget.chat.chatID,
                          attachmentID:
                              '${time.toString()}-${TimeFunctions.microseconds}',
                        );
                        if (url != null) {
                          attachments.add(MessageAttachment(
                            url: url,
                            type: types,
                          ));
                        }
                      }
                    }
                    setState(() {
                      files = <File>[];
                      isLoading = false;
                      disableText = false;
                    });

                    final Message msg = Message(
                      messageID: time.toString(),
                      text: _text.text.trim(),
                      type: _text.text.isNotEmpty
                          ? MessageTypeEnum.text
                          : attachments[0].type,
                      attachment: attachments,
                      sendBy: meUID,
                      sendTo: <MessageReadInfo>[
                        MessageReadInfo(
                          uid: widget.chat.persons
                              .where((String element) => element != getUid())
                              .first,
                          delivered: true,
                          deliveryAt: time,
                          seen: false,
                          seenAt: 0,
                        ),
                      ],
                      timestamp: time,
                    );
                    widget.chat.timestamp = time;
                    widget.chat.lastMessage = msg;
                    _text.clear();

                    widget.chat.unseenMessages.add(msg);
                    await ChatAPI()
                        .sendMessage(chat: widget.chat, selfId: meUID);
                    widget.scrollDown();
                  },
                  // splashRadius: 16,
                  child: Container(
                    alignment: Alignment.center,
                    width: getWidth(context) * 0.12,
                    height: getHeight(context) * 0.06,
                    decoration: const BoxDecoration(
                        color: primaryColor, shape: BoxShape.circle),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (Platform.isIOS) SizedBox(height: 10),
      ],
    );
  }
}
