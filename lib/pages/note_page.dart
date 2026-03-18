import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/note_local_storage_service.dart';
import '../widgets/app_card.dart';
import '../widgets/mobile_shell.dart';
import '../widgets/theme_toggle_button.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  static const routeName = '/note';

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final NoteLocalStorageService _noteStorage = const NoteLocalStorageService();
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  Timer? _debounce;
  DateTime? _updatedAt;

  @override
  void initState() {
    super.initState();
    _loadNote();
    _controller.addListener(_onChanged);
  }

  Future<void> _loadNote() async {
    final note = await _noteStorage.loadNote();
    final updatedAt = await _noteStorage.loadUpdatedAt();
    if (!mounted) {
      return;
    }
    setState(() {
      _controller.text = note;
      _updatedAt = updatedAt;
      _isLoading = false;
    });
  }

  void _onChanged() {
    if (_isLoading) {
      return;
    }
    _debounce?.cancel();
    setState(() {
      _isSaving = true;
    });
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _noteStorage.saveNote(_controller.text.trim());
      if (!mounted) {
        return;
      }
      setState(() {
        _updatedAt = DateTime.now();
        _isSaving = false;
      });
    });
  }

  Future<void> _clearNote() async {
    _debounce?.cancel();
    await _noteStorage.clearNote();
    if (!mounted) {
      return;
    }
    setState(() {
      _controller.clear();
      _updatedAt = null;
      _isSaving = false;
    });
  }

  String _formatUpdatedAt(DateTime dateTime) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, $hour:$minute';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MobileShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Kembali',
                ),
                Expanded(
                  child: Text(
                    'Catatan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const ThemeToggleButton(),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppColors.darkSurface,
                          AppColors.darkSurfaceSoft,
                        ]
                      : [
                          Colors.white,
                          AppColors.blush.withValues(alpha: 0.9),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.shadow,
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceSoft.withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'Untuk Misra',
                      style: TextStyle(
                        color: isDark ? AppColors.darkRose : AppColors.rose,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kalau ada yang pengen disimpan, tulis aja di sini yaa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Catatan ini tersimpan di browser ini, jadi bisa Misra buka lagi kapan pun',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkMutedText
                              : AppColors.mutedText,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.rose,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Catatan untuk hari ini',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              if (_updatedAt != null)
                                Text(
                                  'Terakhir disimpan ${_formatUpdatedAt(_updatedAt!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? AppColors.darkMutedText
                                            : AppColors.mutedText,
                                      ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              expands: true,
                              minLines: null,
                              maxLines: null,
                              maxLength: 1200,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText:
                                    'Tulis apa pun yang lagi Misra rasain atau pengen disimpan di sini',
                                alignLabelWithHint: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                _isSaving
                                    ? 'Menyimpan...'
                                    : 'Tersimpan di browser ini',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? AppColors.darkMutedText
                                          : AppColors.mutedText,
                                    ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed:
                                    _controller.text.trim().isEmpty || _isSaving
                                        ? null
                                        : _clearNote,
                                child: const Text('Kosongkan'),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
