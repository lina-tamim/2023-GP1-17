import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Models/user.dart';
import '../Models/chat.dart';
import '../Models/message.dart';
import '../api/chat_api.dart';
import '../pages/CommonPages/chat/chat_screen.dart';
import '../utils/functions/public_methods.dart';

class ProfileProvider extends ChangeNotifier {
  final CollectionReference userReference =
      FirebaseFirestore.instance.collection('RegularUser');
  Map<String, User> _storedUsers = <String, User>{};

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
        showToast('Unable to open chat');
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
      showToast('Unable to open chat');
    }
  }
}
