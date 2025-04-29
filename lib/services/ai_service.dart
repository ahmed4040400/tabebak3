import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  // API Key - Store securely in production
  static const String apiKey = "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";
  
  static Future<String> getDoctorResponse(String userMessage) async {
    try {
      // Create message history with system prompt
      final messages = [
        {
          "role": "system",
          "content": "You are a professional doctor assistant named Dr. Bot. "
              "Provide helpful, accurate, and compassionate medical advice. "
              "Always make it clear that you're an AI and serious conditions require in-person medical consultation."
        },
        {
          "role": "user",
          "content": userMessage
        }
      ];
      
      return await _makeApiRequest(messages);
    } catch (e) {
      print("Exception in getDoctorResponse: $e");
      return "An unexpected error occurred. Please try again later.";
    }
  }
  
  static Future<String> getChatCompletion(List<Map<String, String>> messages) async {
    try {
      return await _makeApiRequest(messages);
    } catch (e) {
      print("Exception in getChatCompletion: $e");
      return "An unexpected error occurred. Please try again later.";
    }
  }

  static Future<String> _makeApiRequest(List<dynamic> messages) async {
    try {
      // Print debugging info before request
      print("=== MAKING API REQUEST TO OPENROUTER ===");
      
      // Set up headers with proper API key format and all required fields
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        // OpenRouter specific headers
        'HTTP-Referer': 'tabebak.app',
        'X-Title': 'Tabebak Health Assistant'
      };
      
      // Prepare request body
      final Map<String, dynamic> body = {
        "model": "deepseek/deepseek-v3-base:free",
        "messages": messages,
        "temperature": 0.7,
        "max_tokens": 800,
        // Add OpenRouter specific fields
        "transforms": ["middle-out"],
        "route": "fallback"
      };
      
      print("Request body structure: ${jsonEncode(body.keys)}");
      
      // Make the API call with a timeout
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      
      // Print response details
      print("Response status code: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("Successful response received");
        
        if (data.containsKey('choices') && 
            data['choices'] is List && 
            data['choices'].isNotEmpty && 
            data['choices'][0].containsKey('message') &&
            data['choices'][0]['message'].containsKey('content')) {
          
          final content = data['choices'][0]['message']['content'];
          return content ?? "I couldn't generate a proper response.";
        } else {
          print("Invalid response structure: ${response.body}");
          return "I received an unexpected response format.";
        }
      } else {
        print("API Error: ${response.statusCode}, ${response.body}");
        
        // Handle specific error codes
        if (response.statusCode == 401) {
          return "I'm experiencing authentication issues. Please try again later.";
        } else if (response.statusCode == 429) {
          return "I've received too many requests. Please try again in a few minutes.";
        } else {
          return "I'm experiencing technical difficulties. Please try again later.";
        }
      }
    } catch (e, stackTrace) {
      print("Exception in API request: $e");
      print("Stack trace: $stackTrace");
      return "An error occurred while processing your request. Please try again later.";
    }
  }
}