import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../Models/chat.dart';
import '../../Models/message.dart';
import '../../api/chat_api.dart';
import '../../pages/CommonPages/chat/chat_screen.dart';

double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

deleteUrlFromCache(String url) async {
  await CachedNetworkImage.evictFromCache(url);
}

String getUid() => FirebaseAuth.instance.currentUser!.uid;

String numberOfMessages(Chat? chat) {
  if (chat == null) {
    return '0';
  }
  int count = chat.unseenMessages.length;
  return count > 9 ? '9+' : count.toString();
}
