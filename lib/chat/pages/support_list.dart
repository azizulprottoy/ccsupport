// pages/support_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/support_chat_controller.dart';

class SupportListPage extends StatelessWidget {
  final controller = Get.put(SupportChatController());

  @override
  Widget build(BuildContext context) {
    controller.fetchConversations();

    return Scaffold(
      appBar: AppBar(
        title: Text('Support Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.fetchConversations(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.conversations.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No support conversations yet',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchConversations,
          child: ListView.separated(
            itemCount: controller.conversations.length,
            separatorBuilder: (_, __) => Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = controller.conversations[index];
              return _buildConversationTile(conversation);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewChat(),
        child: Icon(Icons.add_comment),
        tooltip: 'Start New Support Chat',
      ),
    );
  }

  Widget _buildConversationTile(SupportConversation conversation) {
    final time = _formatTime(conversation.lastTime);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          conversation.bName[0].toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.bName,
              style: TextStyle(
                fontWeight: conversation.unreadCount > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: conversation.unreadCount > 0 ? Colors.black87 : Colors.grey,
          fontWeight: conversation.unreadCount > 0
              ? FontWeight.w500
              : FontWeight.normal,
        ),
      ),
      trailing: conversation.unreadCount > 0
          ? Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Text(
          '${conversation.unreadCount}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,
      onTap: () {
        Get.to(() => SupportChatPage(), arguments: conversation.supportId);
      },
    );
  }

  String _formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return DateFormat('HH:mm').format(dateTime);
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE').format(dateTime);
      } else {
        return DateFormat('dd/MM/yyyy').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }

  void _startNewChat() {
    // Generate a unique support ID
    final supportId = 'support_${DateTime.now().millisecondsSinceEpoch}';
    Get.to(() => SupportChatPage(), arguments: supportId);
  }
}