import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:techxcel11/Models/ReusedElements.dart';
import '../Models/chat.dart';
import '../Models/message.dart';
import '../utils/functions/public_methods.dart';
import '../utils/functions/time_functions.dart';

class ChatAPI {
  static final FirebaseFirestore _instance = FirebaseFirestore.instance;
  static const String _collection = 'Chat';
  static const String _subCollection = 'Message';

  Stream<List<Message>> messages(String chatID, {int? showAfterTimestamp}) {
    CollectionReference<Map<String, dynamic>> ref = _instance
        .collection(_collection)
        .doc(chatID)
        .collection(_subCollection);

    return ref
        .where('timestamp', isGreaterThan: showAfterTimestamp)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> event) {
      final List<Message> messages = <Message>[];
      for (DocumentSnapshot<Map<String, dynamic>> element in event.docs) {
        final Message temp = Message.fromMap(element.data()!);
        messages.add(temp);
      }
      return messages;
    });
  }

  Stream<List<Chat>> chats() {
    return _instance
        .collection(_collection)
        .where('persons', arrayContains: getUid())
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((QuerySnapshot<Map<String, dynamic>> event) {
      List<Chat> chats = <Chat>[];
      for (DocumentSnapshot<Map<String, dynamic>> element in event.docs) {
        log('MK: here in chats: ${element.data()?['continueOn']}');
        final Chat temp = Chat.fromMap(element.data()!);
        chats.add(temp);
      }
      return chats;
    });
  }

  Future<Chat?> getSingleChat(String chatId) async {
    QuerySnapshot<Map<String, dynamic>> docs = await _instance
        .collection(_collection)
        .where('chatId', isEqualTo: chatId.toString())
        .get();
    if (docs.docs.isNotEmpty) {
      Map<String, dynamic>? data = docs.docs[0].data();
      Chat chat = Chat.fromMap(data);
      return chat;
    } else {
      return null;
    }
  }

  Future<void> sendMessage({required Chat chat, required String selfId}) async {
    final Message? newMessage = chat.lastMessage;
    try {
      if (newMessage != null) {
        await _instance
            .collection(_collection)
            .doc(chat.chatID)
            .collection(_subCollection)
            .doc(newMessage.messageID)
            .set(newMessage.toMap());
      }
      await _instance
          .collection(_collection)
          .doc(chat.chatID)
          .set(chat.toMap());
    } catch (e) {
      // CustomToast.errorToast(message: e.toString());
      // print('CHAT API -> ISSUE -> SEND MESSAGE -> ${e.toString()}');
    }
  }

  updateMessage({
    required Chat chat,
    required Message msg,
    required bool isLast,
  }) async {
    // try {
    await _instance
        .collection(_collection)
        .doc(chat.chatID)
        .collection(_subCollection)
        .doc(msg.messageID)
        .update(msg.updateTick());
    if (isLast) {
      await _instance
          .collection(_collection)
          .doc(chat.chatID)
          .update(chat.updateMessage());
    }
    // } catch (e) {
    //   showToast(e.toString());
    // }
  }

  deleteChat(String id) async {
    Chat? chat = await getSingleChat(id);
    if (chat != null) {
      if (chat.deletedBy == null || chat.deletedBy == getUid()) {
        /////delete or update deletionn chat only by you
        chat.deletedBy = getUid();

        Map<String, dynamic> continueOn = chat.continueOn ?? {};
        continueOn[getUid()] = TimeFunctions.microseconds;
        chat.continueOn = continueOn;

        await _instance.collection(_collection).doc(chat.chatID).update({
          'deletedBy': chat.deletedBy,
          'continueOn': chat.continueOn,
        });
        log('MK: chat will be deleted for you ${chat.chatID}');
      } else if (chat.deletedBy != getUid()) {
        /////chat is deleted by other personn so now you can delete entirely

        log('MK: chat will be deleted completely ${chat.chatID}');
        await deleteChatWithMessages(chat: chat);
      }
    }
  }

  deleteChatWithMessages({required Chat chat}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> docData = await _instance
          .collection(_collection)
          .doc(chat.chatID)
          .collection(_subCollection)
          .get();
      for (DocumentSnapshot<Map<String, dynamic>> doc in docData.docs) {
        await doc.reference.delete();
      }
      await _instance.collection(_collection).doc(chat.chatID).delete();
    } catch (e) {
      toastMessage(e.toString());
    }
  }

  Future<String?> uploadAttachment({
    required File file,
    required String chatID,
    required String attachmentID,
  }) async {
    try {
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('chatMedia/$chatID/$attachmentID')
          .putFile(file);
      String url = (await snapshot.ref.getDownloadURL()).toString();
      return url;
    } catch (e) {
      toastMessage(e.toString());
      return null;
    }
  }

  static String personalChatID(
      {required String chatWith, required String selfId}) {
    int isGreaterThen = selfId.compareTo(chatWith);
    if (isGreaterThen > 0) {
      return '${selfId}-chats-$chatWith';
    } else {
      return '$chatWith-chats-${selfId}';
    }
  }

  static String chatGroupID(String selfId) {
    return '${selfId}-group-${TimeFunctions.microseconds}';
  }
}
