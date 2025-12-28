import 'dart:convert';
import '../model/support_chat_model.dart';


class SupportWebSocketService {
  WebSocketChannel? _channel;
  final String baseUrl = 'ws://YOUR_SERVER_URL'; // Change this
  Function(SupportChatMessage)? onMessageReceived;
  String? currentSupportId;

  void connect(String supportId) {
    currentSupportId = supportId;

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(baseUrl),
        headers: {'supportid': supportId},
      );

      _channel!.stream.listen(
            (message) {
          final data = json.decode(message);
          if (data is List) {
            // Initial messages
            for (var msg in data) {
              onMessageReceived?.call(SupportChatMessage.fromJson(msg));
            }
          } else {
            // New message
            onMessageReceived?.call(SupportChatMessage.fromJson(data));
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      print('Failed to connect: $e');
    }
  }

  void sendMessage(SupportChatMessage message) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(message.toJson()));
    }
  }

  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
    currentSupportId = null;
  }

  bool get isConnected => _channel != null;
}