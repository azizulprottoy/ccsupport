import 'package:get/get.dart';

import '../model/support_chat_model.dart';
import '../sevices/api_service.dart';
import '../sevices/socket.dart';

class SupportChatController extends GetxController {
  final SupportApiService _apiService = SupportApiService();
  final SupportWebSocketService _wsService = SupportWebSocketService();

  var conversations = <SupportConversation>[].obs;
  var messages = <SupportChatMessage>[].obs;
  var isLoading = false.obs;
  var currentSupportId = ''.obs;

  // User info (set these from your auth system)
  String userId = ''; // Set from logged-in user
  String userName = ''; // Set from logged-in user

  @override
  void onInit() {
    super.onInit();
    _wsService.onMessageReceived = _handleNewMessage;
  }

  @override
  void onClose() {
    _wsService.disconnect();
    super.onClose();
  }

  void _handleNewMessage(SupportChatMessage message) {
    if (message.supportId == currentSupportId.value) {
      messages.add(message);
    }
  }

  Future<void> fetchConversations() async {
    try {
      isLoading.value = true;
      conversations.value = await _apiService.getSupportList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load conversations');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openChat(String supportId) async {
    try {
      currentSupportId.value = supportId;
      isLoading.value = true;

      // Fetch existing messages
      messages.value = await _apiService.getChatMessages(supportId);

      // Connect to WebSocket
      _wsService.connect(supportId);

      // Mark as read
      await _apiService.markAsRead(supportId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load chat');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final message = SupportChatMessage(
      supportId: currentSupportId.value,
      bId: userId,
      bName: userName,
      text: text.trim(),
      time: DateTime.now().toIso8601String(),
      sender: 'user',
    );

    try {
      // Optimistically add to UI
      messages.add(message);

      // Send via WebSocket
      _wsService.sendMessage(message);

      // Also send via HTTP as backup
      await _apiService.sendMessage(message);
    } catch (e) {
      // Remove from UI if failed
      messages.remove(message);
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  void closeChat() {
    _wsService.disconnect();
    messages.clear();
    currentSupportId.value = '';
  }
}