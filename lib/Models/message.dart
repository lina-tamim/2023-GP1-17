import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/message_type_enum.dart';
import 'message_attachment.dart';
import 'message_read_info.dart';

class Message {
  Message({
    required this.messageID,
    required this.text,
    required this.type,
    required this.attachment,
    required this.sendBy,
    this.sendByName,
    required this.sendTo,
    required this.timestamp,
  });

  final String messageID;
  final String? text;
  final MessageTypeEnum type;
  final List<MessageAttachment> attachment;
  final String sendBy;
  String? sendByName;
  final List<MessageReadInfo> sendTo;
  final int timestamp;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'messageId': messageID,
      'text': text,
      'type': type.json,
      'attachment': attachment.map((MessageAttachment x) => x.toMap()).toList(),
      'sendBy': sendBy,
      'sendTo': sendTo.map((MessageReadInfo x) => x.toMap()).toList(),
      'timestamp': timestamp,
    };
  }

  Map<String, dynamic> updateTick() {
    return <String, dynamic>{
      'sendTo': sendTo.map((MessageReadInfo x) => x.toMap()).toList(),
    };
  }

  // ignore: sort_constructors_first
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageID: map['messageId'] ?? '',
      text: map['text'],
      type: MessageTypeEnumConvertor.toEnum(map['type'] ?? 'text'),
      attachment: List<MessageAttachment>.from(
          map['attachment']?.map((dynamic x) => MessageAttachment.fromMap(x))),
      sendBy: map['sendBy'] ?? '',
      sendTo: List<MessageReadInfo>.from(
          map['sendTo']?.map((dynamic x) => MessageReadInfo.fromMap(x))),
      timestamp: map['timestamp']?.toInt() ?? 0,
    );
  }
}
