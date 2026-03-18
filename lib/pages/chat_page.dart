import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/chat_message.dart';
import '../services/chat_api_service.dart';
import '../services/chat_local_storage_service.dart';
import '../widgets/app_card.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/mobile_shell.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  static const routeName = '/chat';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const String _introMessage =
      'Aku Syra, singkatan kecil dari nama Syarif dan Misra. Jadi kalau Syarif lagi sibuk, aku tetap di sini buat nemenin kamu yaaa.';
  static const int _maxStoredMessages = 40;
  static const String _syraAvatarAssetPath = 'assets/images/syra.png';

  final ChatApiService _chatApiService = const ChatApiService();
  final ChatLocalStorageService _chatLocalStorageService =
      const ChatLocalStorageService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  String? _retryMessage;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final storedMessages = await _chatLocalStorageService.loadMessages();
      if (!mounted) {
        return;
      }

      setState(() {
        _messages = storedMessages.isEmpty
            ? [_buildIntroMessage()]
            : _trimStoredMessages(storedMessages);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _messages = [_buildIntroMessage()];
        _isLoading = false;
        _errorMessage = 'Riwayat chat belum bisa dibuka, tapi kamu masih bisa mulai ngobrol.';
      });
    }
  }

  ChatMessage _buildIntroMessage() {
    return ChatMessage(
      id: 'intro',
      role: ChatRole.assistant,
      text: _introMessage,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _clearChat() async {
    if (_isSending) {
      return;
    }

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus percakapan?'),
          content: const Text(
            'Riwayat chat di browser ini akan dihapus dan Syra akan mulai lagi dari pesan awal.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !mounted) {
      return;
    }

    final resetMessages = [_buildIntroMessage()];
    setState(() {
      _messages = resetMessages;
      _errorMessage = null;
      _retryMessage = null;
    });
    await _chatLocalStorageService.saveMessages(resetMessages);
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    final historyBeforeSend = List<ChatMessage>.from(_messages);

    final userMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: ChatRole.user,
      text: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _errorMessage = null;
      _retryMessage = null;
      _isSending = true;
      _messages = _trimStoredMessages([..._messages, userMessage]);
    });
    _controller.clear();
    _scrollToBottom();

    try {
      await _chatLocalStorageService.saveMessages(_messages);
      final reply = await _chatApiService.sendMessage(
        message: text,
        history: historyBeforeSend,
      );
      final aiMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: ChatRole.assistant,
        text: reply,
        createdAt: DateTime.now(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _messages = _trimStoredMessages([..._messages, aiMessage]);
      });
      await _chatLocalStorageService.saveMessages(_messages);
      _scrollToBottom();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _retryMessage = text;
        _errorMessage = _mapChatError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _retryLastMessage() async {
    final retryMessage = _retryMessage;
    if (retryMessage == null || _isSending) {
      return;
    }

    final history = List<ChatMessage>.from(_messages);

    setState(() {
      _errorMessage = null;
      _isSending = true;
    });

    try {
      final retryHistory = List<ChatMessage>.from(history);
      for (var index = retryHistory.length - 1; index >= 0; index--) {
        final item = retryHistory[index];
        if (item.isUser && item.text == retryMessage) {
          retryHistory.removeAt(index);
          break;
        }
      }

      final reply = await _chatApiService.sendMessage(
        message: retryMessage,
        history: retryHistory,
      );

      final aiMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: ChatRole.assistant,
        text: reply,
        createdAt: DateTime.now(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _retryMessage = null;
        _messages = _trimStoredMessages([..._messages, aiMessage]);
      });
      await _chatLocalStorageService.saveMessages(_messages);
      _scrollToBottom();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _mapChatError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  String _mapChatError(Object error) {
    if (error is TimeoutException) {
      return 'Syra lagi butuh waktu sedikit lebih lama. Coba lagi ya.';
    }

    if (error is ChatApiException) {
      return error.message;
    }

    return 'Syra belum bisa balas sekarang. Coba lagi sebentar ya.';
  }

  List<ChatMessage> _trimStoredMessages(List<ChatMessage> messages) {
    if (messages.length <= _maxStoredMessages) {
      return messages;
    }

    return messages.sublist(messages.length - _maxStoredMessages);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(6, 2, 2, 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'Kembali ke beranda',
                    iconSize: 18,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Syra AI',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _messages.length <= 1 || _isSending ? null : _clearChat,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (_errorMessage != null) ...[
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.rose,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.text,
                            ),
                      ),
                    ),
                    if (_retryMessage != null) ...[
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: _isSending ? null : _retryLastMessage,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      AppColors.cream.withValues(alpha: 0.88),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.rose),
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada chat. Kalau mau, mulai duluan aja ya.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppColors.mutedText),
                            ),
                          )
                        : ListView(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 4, bottom: 8),
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  left: 24,
                                  right: 24,
                                  bottom: 14,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  'Syra ada di sini buat nemenin Misra. Syra dibuat Syarif khusus untuk kamu.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.mutedText,
                                        height: 1.45,
                                      ),
                                ),
                              ),
                              ..._messages.map(
                                (message) => ChatBubble(
                                  message: message,
                                  assistantAvatarAssetPath:
                                      _syraAvatarAssetPath,
                                ),
                              ),
                              if (_isSending)
                                ChatBubble(
                                  message: ChatMessage(
                                    id: 'typing',
                                    role: ChatRole.assistant,
                                    text: 'Syra lagi ngetik buat Misra...',
                                    createdAt: DateTime.now(),
                                  ),
                                  assistantAvatarAssetPath:
                                      _syraAvatarAssetPath,
                                ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    AppColors.cream.withValues(alpha: 0.96),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 400,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Cerita ke Syra di sini...',
                        counterText: '',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.arrow_upward_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cerita pelan-pelan aja. Syra akan jawab dengan lembut.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText,
                    fontSize: 11.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
