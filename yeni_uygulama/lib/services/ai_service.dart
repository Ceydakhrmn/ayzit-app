import 'dart:convert';

import 'package:http/http.dart' as http;

class AiChatMessage {
  AiChatMessage({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, String> toJson() => {
        'role': role,
        'content': content,
      };
}

class AiService {
  AiService({required this.baseUrl});

  final String baseUrl;

  Future<String> chat({
    required List<AiChatMessage> messages,
    String? locale,
  }) async {
    final uri = Uri.parse('$baseUrl/ai/chat');
    final payload = {
      'messages': messages.map((m) => m.toJson()).toList(),
      if (locale != null && locale.isNotEmpty) 'locale': locale,
    };
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('AI request failed (${response.statusCode})');
    }
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic> && data['reply'] is String) {
      return data['reply'] as String;
    }
    throw Exception('Invalid AI response');
  }

  Future<String> advice({
    required String summary,
    String? locale,
  }) async {
    final uri = Uri.parse('$baseUrl/ai/advice');
    final payload = {
      'summary': summary,
      if (locale != null && locale.isNotEmpty) 'locale': locale,
    };
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('AI request failed (${response.statusCode})');
    }
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic> && data['advice'] is String) {
      return data['advice'] as String;
    }
    throw Exception('Invalid AI response');
  }

  Future<String> summarize({
    required String notes,
    String? locale,
  }) async {
    final uri = Uri.parse('$baseUrl/ai/summary');
    final payload = {
      'notes': notes,
      if (locale != null && locale.isNotEmpty) 'locale': locale,
    };
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('AI request failed (${response.statusCode})');
    }
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic> && data['summary'] is String) {
      return data['summary'] as String;
    }
    throw Exception('Invalid AI response');
  }
}
