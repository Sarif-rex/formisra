import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.assistantAvatarAssetPath,
  });

  final ChatMessage message;
  final bool showAvatar;
  final String? assistantAvatarAssetPath;

  Widget _buildAssistantAvatar() {
    final assetPath = assistantAvatarAssetPath?.trim() ?? '';
    if (assetPath.isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          assetPath,
          width: 34,
          height: 34,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildAssistantFallback(),
        ),
      );
    }
    return _buildAssistantFallback();
  }

  Widget _buildAssistantFallback() {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: AppColors.softPink,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'S',
        style: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 290),
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
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser && showAvatar) ...[
            _buildAssistantAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(child: bubble),
          if (isUser && showAvatar) ...[
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.blush,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.favorite_rounded,
                size: 18,
                color: AppColors.rose,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
