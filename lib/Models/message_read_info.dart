class MessageReadInfo {
  MessageReadInfo({
    required this.uid,
    this.delivered = true,
    this.seen = false,
    this.deliveryAt,
    this.seenAt,
  });

  final String uid;
  final bool delivered;
  bool seen;
  final int? deliveryAt;
  int? seenAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'delivered': delivered,
      'seen': seen,
      'deliveryAt': deliveryAt,
      'seenAt': seenAt,
    };
  }

  // ignore: sort_constructors_first
  factory MessageReadInfo.fromMap(Map<String, dynamic> map) {
    return MessageReadInfo(
      uid: map['uid'] ?? '',
      delivered: map['delivered'] ?? false,
      seen: map['seen'] ?? false,
      deliveryAt: map['deliveryAt'],
      seenAt: map['seenAt'],
    );
  }
}
