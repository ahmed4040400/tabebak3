import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Message {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUserMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotController extends GetxController {
  final RxList<Message> messages = <Message>[].obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // Add welcome message
    messages.add(
      Message(
        text: "Hello! I'm Dr. Bot. How can I help you today?",
        isUserMessage: false,
      ),
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    final userMessage = Message(
      text: messageController.text.trim(),
      isUserMessage: true,
    );
    messages.add(userMessage);
    messageController.clear();

    // Scroll to the bottom of the chat
    _scrollToBottom();

    // Simulate bot thinking
    Future.delayed(const Duration(seconds: 1), () {
      _processBotResponse(userMessage.text);
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _processBotResponse(String userMessage) {
    // Simple predefined responses
    final lowercaseMessage = userMessage.toLowerCase();
    String botResponse;

    if (lowercaseMessage.contains('hello') ||
        lowercaseMessage.contains('hi') ||
        lowercaseMessage.contains('hey')) {
      botResponse = "Hello there! How are you feeling today?";
    } else if (lowercaseMessage.contains('pain') ||
        lowercaseMessage.contains('hurt')) {
      botResponse =
          "I'm sorry to hear you're in pain. Can you describe where it hurts and how severe it is on a scale of 1-10?";
    } else if (lowercaseMessage.contains('headache') ||
        lowercaseMessage.contains('head pain')) {
      botResponse =
          "Headaches can have many causes. Are you hydrated enough? Have you been getting adequate sleep? If this is severe or persistent, please consult with one of our doctors.";
    } else if (lowercaseMessage.contains('appointment') ||
        lowercaseMessage.contains('book') ||
        lowercaseMessage.contains('schedule')) {
      botResponse =
          "To book an appointment, you can use the Doctors tab to find a specialist that suits your needs, then tap on 'Book Now'.";
    } else if (lowercaseMessage.contains('thank')) {
      botResponse = "You're welcome! Is there anything else I can help with?";
    } else {
      botResponse =
          "I understand you're concerned about your health. For more specific advice, I recommend consulting with one of our specialists. Is there something specific you'd like to know?";
    }

    // Add bot response to the chat
    messages.add(Message(text: botResponse, isUserMessage: false));

    // Scroll to the bottom of the chat
    _scrollToBottom();
  }
}

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safe controller initialization
    late ChatbotController chatController;

    if (!Get.isRegistered<ChatbotController>()) {
      chatController = Get.put(ChatbotController());
    } else {
      chatController = Get.find<ChatbotController>();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Assistant'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Chat suggestion chips
          Container(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: [
                _buildSuggestionChip(
                  context,
                  "I have a headache",
                  chatController,
                ),
                _buildSuggestionChip(
                  context,
                  "Book appointment",
                  chatController,
                ),
                _buildSuggestionChip(
                  context,
                  "Medication advice",
                  chatController,
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: chatController.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  return _buildMessageBubble(message, context);
                },
              ),
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: chatController.messageController,
                      decoration: InputDecoration(
                        hintText: "Type your health concern...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => chatController.sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: chatController.sendMessage,
                    mini: true,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 2,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(
    BuildContext context,
    String text,
    ChatbotController controller,
  ) {
    return ActionChip(
      label: Text(text),
      backgroundColor: Colors.grey[100],
      side: BorderSide(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      ),
      onPressed: () {
        controller.messageController.text = text;
        controller.sendMessage();
      },
    );
  }

  Widget _buildMessageBubble(Message message, BuildContext context) {
    final isUser = message.isUserMessage;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot avatar
          if (!isUser)
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.health_and_safety, color: Colors.white),
              radius: 16,
            ),

          const SizedBox(width: 8),

          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // User avatar
          if (isUser)
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.white),
              radius: 16,
            ),
        ],
      ),
    );
  }
}
