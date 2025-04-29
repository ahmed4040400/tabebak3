import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepseekService {
  static const String apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  final String apiKey;

  DeepseekService({required this.apiKey});

  Future<String> getChatResponse(String message) async {
    return await _makeApiRequest([
      {
        "role": "system",
        "content": "You are a professional doctor assistant named Dr. Bot. "
            "Provide helpful, accurate, and compassionate medical advice. "
            "Use a warm and professional tone when addressing health concerns."
      },
      {
        "role": "user",
        "content": message
      }
    ]);
  }

  Future<String> getChatResponseWithHistory(List<Map<String, String>> conversationHistory) async {
    return await _makeApiRequest(conversationHistory);
  }

  Future<String> _makeApiRequest(List<dynamic> messages) async {
    try {
      print("Making API request to OpenRouter with key: ${apiKey.substring(0, 10)}...");
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'tabebak.app', // OpenRouter requirement
        },
        body: jsonEncode({
          "model": "deepseek/deepseek-v3-base:free",
          "messages": messages,
          "temperature": 0.7,
          "max_tokens": 500
        }),
      );
      print("API Response Status: ${response.statusCode}");
      if (response.statusCode != 200) {
        print("API Response Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 
          "I'm sorry, I couldn't understand that. Could you please rephrase?";
      } else {
        return "I'm experiencing some technical difficulties. Please try again later.";
      }
    } catch (e) {
      print('OpenRouter Service Error: $e');
      return "An error occurred while processing your request. Please try again later.";
    }
  }
}