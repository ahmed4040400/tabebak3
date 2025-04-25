import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorAIService {
  static const String apiEndpoint = 'https://api.deepseek.com/chat/completions';
  static const String apiKey = 'sk-8541fb10c0b54acd804e81b043f1ffe6';

  static Future<String> getResponse(String userMessage) async {
    try {
      // Prepare the message history with system and user messages
      final messages = [
        {
          "role": "system",
          "content":
              """You are a medical AI assistant that provides helpful, accurate, and compassionate medical advice. Use a professional but friendly tone. keep your answer short and comprehinsive. dont use text decoration stuff in your response, your name is dr. bot
          When discussing symptoms, provide possible causes and suggest appropriate actions. Use medical terminology but explain it in simple terms for the patient to understand.
          when you get asked for how to book an appintment you say go to the doctors tab find a doctor specialized in your case and book an appointment with him.
          when you get asked for a medical advice you give him an advice in a fun an warm way
          don't use any text decoration stuff in your response like * and emogies
              """,
        },
        {"role": "user", "content": userMessage},
      ];

      // Prepare the request body
      final requestBody = {
        "model": "deepseek-chat",
        "messages": messages,
        "stream": false,
      };

      print(
        "🔄 Sending request to DeepSeek API with body: ${jsonEncode(requestBody)}",
      );

      // Make the API request
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      );

      // Print the raw response
      print("📥 DeepSeek API Response Status: ${response.statusCode}");
      print("📥 DeepSeek API Response Body: ${response.body}");

      // Check if the request was successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Print the parsed response structure
        print("✅ DeepSeek API Parsed Response: $data");

        // Extract the assistant's response from the API response
        final assistantResponse = data['choices'][0]['message']['content'];
        print("💬 Assistant's Response: $assistantResponse");
        return assistantResponse;
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        return 'I apologize, but I encountered an error while processing your request. Please try again later.';
      }
    } catch (e) {
      print('❌ Exception in DoctorAIService: $e');
      return 'I apologize for the inconvenience, but there was an error processing your request. Please try again.';
    }
  }
}
