import 'package:techxcel11/Models/user.dart';
import 'message.dart';

class Chat {
  Chat({
    required this.chatID,
    required this.persons,
    required this.unseenMessages,
    this.lastMessage,
    this.timestamp = 0,
    this.name,
    this.isUnredByMe = false,
    this.description,
    this.imageURL,
    this.createdDate,
    this.lastMessageText,
    this.users = const [],
    this.userInstances = const [],
  });

  final String chatID;
  final List<String> persons;
  final bool isUnredByMe;
  Message? lastMessage;
  String? lastMessageText;
  List<Message> unseenMessages = [];
  int timestamp;

  String? name;
  String? description;
  String? imageURL;
  final int? createdDate;
  List
      users; /////// list of kind will be in this [{Condition: Un Read, Uid: gdPlSYL1guZdidoyee7BPVhApPs1}]
  List<User> userInstances = [];

//////this is in order to make model compatible with old code
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatId': chatID,
      'persons': persons,
      'lastMessage': lastMessage != null ? lastMessage!.toMap() : null,
      'unseenMessages': unseenMessages.map((Message x) => x.toMap()).toList(),
      'timestamp': timestamp,
    };
  }

  Map<String, dynamic> updateMessage() {
    return <String, dynamic>{
      'lastMessage': lastMessage != null ? lastMessage!.toMap() : null,
      'unseenMessages': unseenMessages.map((Message x) => x.toMap()).toList(),
      'timestamp': timestamp,
    };
  }

  // ignore: sort_constructors_first
  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      chatID: map['chatId'] ?? '',
      persons: List<String>.from(map['persons']),
      lastMessage: Message.fromMap(map['lastMessage']),
      unseenMessages: map['unseenMessages'] == null
          ? <Message>[]
          : List<Message>.from(
              map['unseenMessages']?.map((dynamic x) => Message.fromMap(x))),
      timestamp: map['timestamp'] ?? 0,
    );
  }
}
