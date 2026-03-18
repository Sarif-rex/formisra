import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../models/chat_message.dart';

class ChatApiService {
  const ChatApiService();

  static const int _maxHistoryMessages = 8;
  static const Duration _requestTimeout = Duration(seconds: 18);

  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> history,
  }) async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/chat');
    final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': message.trim(),
            'history': history
                .takeLast(_maxHistoryMessages)
                .map(
                  (item) => {
                    'role': item.role.name,
                    'text': item.text.trim(),
                  },
                )
                .toList(),
          }),
        )
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = response.body.isEmpty
          ? null
          : jsonDecode(response.body) as Map<String, dynamic>;
      throw ChatApiException(
        message:
            payload?['error'] as String? ?? 'Gagal menghubungi backend.',
        statusCode: response.statusCode,
        code: payload?['code'] as String?,
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final reply = payload['reply'] as String?;
    if (reply == null || reply.trim().isEmpty) {
      throw const ChatApiException(message: 'Balasan Syra kosong.');
    }

    return reply.trim();
  }
}

class ChatApiException implements Exception {
  const ChatApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

extension on List<ChatMessage> {
  Iterable<ChatMessage> takeLast(int count) {
    if (length <= count) {
      return this;
    }

    return skip(length - count);
  }
}
