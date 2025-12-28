class SupportChatMessage {
  final String? id;
  final String supportId;
  final String bId;
  final String bName;
  final String text;
  final String time;
  final String sender;
  final bool read;

  SupportChatMessage({
    this.id,
    required this.supportId,
    required this.bId,
    required this.bName,
    required this.text,
    required this.time,
    required this.sender,
    this.read = false,
  });

  factory SupportChatMessage.fromJson(Map<String, dynamic> json) {
    return SupportChatMessage(
      id: json['_id'],
      supportId: json['supportId'] ?? '',
      bId: json['bId'] ?? '',
      bName: json['bName'] ?? '',
      text: json['text'] ?? '',
      time: json['time'] ?? '',
      sender: json['sender'] ?? 'user',
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supportId': supportId,
      'bId': bId,
      'bName': bName,
      'text': text,
      'time': time,
      'sender': sender,
      'read': read,
    };
  }
}

// models/support_conversation.dart
class SupportConversation {
  final String supportId;
  final String bName;
  final String bId;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;

  SupportConversation({
    required this.supportId,
    required this.bName,
    required this.bId,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
  });

  factory SupportConversation.fromJson(Map<String, dynamic> json) {
    return SupportConversation(
      supportId: json['_id'] ?? '',
      bName: json['bName'] ?? 'Unknown',
      bId: json['bId'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastTime: json['lastTime'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}