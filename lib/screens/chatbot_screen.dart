import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chatbot_controller.dart';
import 'dart:convert'; // Add this import for UTF-8 decoding

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  // Helper function to detect if text contains RTL characters (primarily Arabic)
  bool _isRTL(String text) {
    // Check for Arabic Unicode range (0x0600-0x06FF)
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }
  
  // Helper function to fix encoding issues with Arabic text
  String _fixEncoding(String text) {
    try {
      // Check if the text might be incorrectly encoded
      if (text.contains('Ø') || text.contains('Ù') || text.contains('Ø§')) {
        // Try different approaches to fix encoding
        
        // Approach 1: UTF-8 decode after Latin1 encode
        final bytes = latin1.encode(text);
        final decoded = utf8.decode(bytes, allowMalformed: true);
        
        // Return the decoded text if it looks like Arabic
        if (_isRTL(decoded)) {
          return decoded;
        }
        
        // Approach 2: Try with a different encoding path
        try {
          final decodedAlt = utf8.decode(latin1.encode(text), allowMalformed: true);
          return decodedAlt;
        } catch (e) {
          // Fallback to original if all attempts fail
        }
      }
    } catch (e) {
      // If any errors occur during decoding, return the original
    }
    return text;
  }

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

          // Typing indicator
          Obx(() => chatController.isProcessing
              ? Container(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.health_and_safety, color: Colors.white),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Dr. Bot is typing...",
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),

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
        controller.addSuggestion(text);
      },
    );
  }

  Widget _buildMessageBubble(Message message, BuildContext context) {
    final isUser = message.isUserMessage;
    
    // Apply encoding fix to the message text
    final fixedText = _fixEncoding(message.text);
    final isRTL = _isRTL(fixedText);

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
              child: Directionality(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  fixedText,
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontFamily: 'Arial',
                  ),
                  textAlign: isRTL ? TextAlign.right : TextAlign.left,
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
