import 'package:flutter/material.dart';

class SupportChatPage extends StatelessWidget {
  final controller = Get.find<SupportChatController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final supportId = Get.arguments as String;
    controller.openChat(supportId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Support Chat'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            controller.closeChat();
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet. Start the conversation!',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              // Auto scroll to bottom when new messages arrive
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });

              return ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return _buildMessageBubble(message);
                },
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SupportChatMessage message) {
    final isMe = message.sender == 'user';
    final time = _formatMessageTime(message.time);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMe ? 50 : 0,
          right: isMe ? 0 : 50,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
            bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.bName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            SizedBox(height: 4),
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (messageController.text.trim().isNotEmpty) {
                  controller.sendMessage(messageController.text);
                  messageController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '';
    }
  }
}