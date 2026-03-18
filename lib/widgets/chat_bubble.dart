import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isUser ? AppColors.rose : Colors.white,
          borderRadius: BorderRadius.circular(22).copyWith(
            bottomRight: Radius.circular(isUser ? 8 : 22),
            bottomLeft: Radius.circular(isUser ? 22 : 8),
          ),
          border: Border.all(
            color: isUser ? AppColors.rose : AppColors.border,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isUser ? Colors.white : AppColors.text,
                height: 1.45,
              ),
        ),
      ),
    );
  }
}
