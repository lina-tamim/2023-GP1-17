import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/user.dart';
import '../Models/ReusedElements.dart';
import '../Models/chat.dart';
import '../Models/message.dart';
import '../Models/message_read_info.dart';
import '../api/chat_api.dart';
import '../pages/CommonPages/chat/chat_screen.dart';
import '../utils/functions/public_methods.dart';

class ProfileProvider extends ChangeNotifier {
  final CollectionReference userReference =
      FirebaseFirestore.instance.collection('RegularUser');
  Map<String, User> _storedUsers = <String, User>{};

  bool _containsUnseenReports = false;

  bool get containsUnseenReports => _containsUnseenReports;

  set containsUnseenReports(bool value) {
    _containsUnseenReports = value;
  }

  ProfileProvider() {
    initRealtimeListener();
    listenToReports();
  }

  int _chatCount = 0;

  int get chatCount => _chatCount;

  set chatCount(int value) {
    _chatCount = value;
    notifyListeners();
  }

  Future<User?> searchUser({required String? uid}) async {
    if (uid == null || uid == '' || uid == 'null' || uid.isEmpty) {
      return null;
    }
    User? user = _storedUsers[uid];
    return user ?? await _loadUser(uid);
  }

  Future<User?> _loadUser(String uid) async {
    final User? user = await getSpecificUser(uid: uid);
    if (user?.uid != null) {
      _storedUsers.addAll(<String, User>{(user?.uid)!: user!});
    }
    return user;
  }

  Future<User?> getSpecificUser({required String uid}) async {
    try {
      final DocumentSnapshot doc = await userReference.doc(uid).get();
      return doc.exists
          ? User.fromJson(doc.data() as Map<String, dynamic>, doc.id)
          : null;
    } catch (e) {
      // CustomToast.errorToast(message: e.toString());
      return null;
    }
  }

  gotoChat(BuildContext context, String? email) async {
    String selfId = getUid();

    final QuerySnapshot snapshot =
        await userReference.where('email', isEqualTo: email).limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      final Map<String, dynamic>? userData =
          snapshot.docs[0].data() as Map<String, dynamic>?;
      if (userData == null) {
        toastMessage('Unable to open chat');
        return;
      }

      final username = userData['username'] ?? '';
      final imageURL = userData['imageURL'] ?? '';
      final uid = snapshot.docs[0].id;
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ChatScreen(
          chat: Chat(
            chatID: ChatAPI.personalChatID(chatWith: uid, selfId: selfId),
            persons: <String>[selfId, uid],
            unseenMessages: <Message>[],
          ),
          chatWith: User(
            name: username,
            profileUrl: imageURL,
            uid: uid,
          ),
        );
      }));
    } else {
      toastMessage('Unable to open chat');
    }
  }

  void initRealtimeListener() {
    ChatAPI().chats().listen((List<Chat> chats) {
      // Calculate chat count based on the updated chat data
      int count = chats
          .where((element) => element.deletedBy != getUid())
          .where((Chat chat) =>
              chat.lastMessage?.sendTo
                  .firstWhere(
                    (MessageReadInfo element) => element.uid == getUid()
                    //     &&
                    // (element.deliveryAt ?? 0) >=
                    //     (chat.continueOn?[getUid()] ?? 0)
                    ,
                    orElse: () => MessageReadInfo(uid: '', seen: true),
                  )
                  .seen ==
              false)
          .length;
      if (count != _chatCount) {
        _chatCount = count;
        notifyListeners(); // Notify listeners only when the chat count changes
      }
    });
  }

  Future<void> listenToReports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInEmail') ?? '';
    if (email.isEmpty) {
      return;
    }
    FirebaseFirestore.instance
        .collection('Report')
        .where('reportedUserId', isEqualTo: email)
        .where('status', isEqualTo: 'Accepted')
        .snapshots()
        .listen((snapshot) {
      bool hasUnseenReports = false;
      bool hasReportedPosts = snapshot.docs.isNotEmpty;

      // Check if there are any unseen reports
      for (var doc in snapshot.docs) {
        if (doc.data()['seen'] == false) {
          hasUnseenReports = true;
          break;
        }
      }

      // Update the provider variables
      _containsUnseenReports = hasUnseenReports;
      notifyListeners();
    });
  }
}
