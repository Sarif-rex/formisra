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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 290),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: isUser
            ? (isDark ? AppColors.darkRose : AppColors.rose)
            : (isDark ? AppColors.darkSurface : const Color(0xFFFFFDFD)),
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomRight: Radius.circular(isUser ? 6 : 20),
          bottomLeft: Radius.circular(isUser ? 20 : 6),
        ),
        border: Border.all(
          color: isUser
              ? (isDark ? AppColors.darkRose : AppColors.rose)
              : (isDark ? AppColors.darkBorder : const Color(0xFFF0D9DF)),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        message.text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isUser
                  ? Colors.white
                  : (isDark ? AppColors.darkText : AppColors.text),
              height: 1.45,
            ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSoft : AppColors.blush,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.favorite_rounded,
                size: 16,
                color: isDark ? AppColors.darkRose : AppColors.rose,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
