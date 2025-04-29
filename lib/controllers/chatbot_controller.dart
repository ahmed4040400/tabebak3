import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/doctor_ai_service.dart';

// sk-8541fb10c0b54acd804e81b043f1ffe6
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

  // Track conversation history to maintain context for AI
  final List<Map<String, String>> _conversationHistory = [];

  final RxBool _isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Add welcome message
    final welcomeMessage =
        "Hello! I'm Dr. Bot. How can I help you today? "
        "I'm a medical assistant designed to provide general health information, "
        "but please remember to consult with a real doctor for any serious concerns.";

    messages.add(Message(text: welcomeMessage, isUserMessage: false));

    // Initialize conversation history with system message
    _conversationHistory.add({
      "role": "system",
      "content":
          "You are a professional doctor assistant named Dr. Bot. "
          "Provide helpful, accurate, and compassionate medical advice. "
          "Use a warm and professional tone when addressing health concerns. "
          "When discussing symptoms, provide possible causes and suggest appropriate actions. "
          "Use medical terminology but explain it in simple terms for the patient to understand.",
    });

    _conversationHistory.add({"role": "assistant", "content": welcomeMessage});
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    final userMessageText = messageController.text.trim();

    final userMessage = Message(text: userMessageText, isUserMessage: true);

    // Add message to UI list
    messages.add(userMessage);

    // Add message to conversation history
    _conversationHistory.add({"role": "user", "content": userMessageText});

    messageController.clear();

    // Scroll to the bottom of the chat
    _scrollToBottom();

    // Process the response
    _processBotResponse();
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

  void _processBotResponse() async {
    // Show typing indicator
    _isProcessing.value = true;

    // Set a fallback timer with much longer timeout
    Timer? fallbackTimer;
    fallbackTimer = Timer(const Duration(minutes: 3), () {
      if (_isProcessing.value) {
        print(
          "ChatbotController: Fallback timer triggered after 3 minutes - request may still be processing",
        );
        _isProcessing.value = false;

        final errorMessage =
            "I'm sorry, but this request is taking longer than expected. Your answer is still being processed and will appear when ready.";

        // Add error message to UI
        messages.add(Message(text: errorMessage, isUserMessage: false));

        // Add error to conversation history
        _conversationHistory.add({
          "role": "assistant",
          "content": errorMessage,
        });

        _scrollToBottom();
      }
    });

    try {
      // Get the last user message
      final lastUserMessage =
          _conversationHistory.lastWhere(
            (message) => message["role"] == "user",
            orElse: () => {"role": "user", "content": "Hello"},
          )["content"] ??
          "Hello";

      print(
        "ChatbotController: Starting DeepSeek API request with message: $lastUserMessage",
      );

      // Use DoctorAIService with DeepSeek API
      final botResponse = await DoctorAIService.getResponse(lastUserMessage);

      // Cancel fallback timer since we got a response
      fallbackTimer.cancel();

      print("ChatbotController: Received response from DeepSeek API");

      // Only proceed if we're still processing (fallback timer hasn't fired)
      if (_isProcessing.value) {
        if (botResponse.isEmpty) {
          print("ChatbotController: Empty response received");
          throw Exception("Empty response received from API");
        }

        // Add to UI messages
        messages.add(Message(text: botResponse, isUserMessage: false));

        // Add to conversation history
        _conversationHistory.add({"role": "assistant", "content": botResponse});

        print("ChatbotController: Message added to conversation");
      }
    } catch (e) {
      // Cancel fallback timer
      fallbackTimer.cancel();

      print("ChatbotController: Error getting AI response: $e");

      // Only proceed if we're still processing (fallback timer hasn't fired)
      if (_isProcessing.value) {
        final errorMessage =
            "I'm sorry, I encountered an error while processing your request. Please try again with a different question.";

        // Add error message to UI
        messages.add(Message(text: errorMessage, isUserMessage: false));

        // Add error to conversation history
        _conversationHistory.add({
          "role": "assistant",
          "content": errorMessage,
        });
      }
    } finally {
      // Stop typing indicator if it's still active
      if (_isProcessing.value) {
        _isProcessing.value = false;
        _scrollToBottom();
      }
    }
  }

  void addSuggestion(String text) {
    messageController.text = text;
    sendMessage();
  }

  bool get isProcessing => _isProcessing.value;
}
