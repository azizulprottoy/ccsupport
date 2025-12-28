import 'dart:convert';
import 'package:http/http.dart';
import '../model/support_chat_model.dart';

class SupportApiService {
  final String baseUrl = 'http://YOUR_SERVER_URL:5000'; // Change this

  Future<List<SupportConversation>> getSupportList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/support'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SupportConversation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load support list');
      }
    } catch (e) {
      print('Error fetching support list: $e');
      rethrow;
    }
  }

  Future<List<SupportChatMessage>> getChatMessages(String supportId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schat/$supportId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SupportChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(SupportChatMessage message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addschat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String supportId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/schat/mark-read/$supportId'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error marking as read: $e');
    }
  }
}