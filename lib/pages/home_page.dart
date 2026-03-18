import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/greeting_service.dart';
import '../widgets/menu_card.dart';
import '../widgets/mobile_shell.dart';
import '../widgets/theme_toggle_button.dart';
import 'chat_page.dart';
import 'timeline_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final DateTime _startedAt = DateTime(2024, 11, 1);

  late Timer _timer;
  Duration _duration = DateTime.now().difference(_startedAt);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _duration = DateTime.now().difference(_startedAt);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final greeting = GreetingService.forCurrentTime(DateTime.now());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = _duration.inDays;
    final hours = _duration.inHours.remainder(24);
    final minutes = _duration.inMinutes.remainder(60);
    final seconds = _duration.inSeconds.remainder(60);

    return MobileShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, kesayangan Syarif',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        greeting,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? AppColors.darkMutedText
                                  : AppColors.mutedText,
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const ThemeToggleButton(),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppColors.darkSurface,
                          AppColors.darkSurfaceSoft,
                        ]
                      : [
                          Colors.white,
                          AppColors.blush.withValues(alpha: 0.92),
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
                          : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'Ruang kecil untuk Misra',
                      style: TextStyle(
                        color: isDark ? AppColors.darkRose : AppColors.rose,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kalau Misra lagi pengen ditemenin, Syra ada di sini yaa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Kalau hati Misra lagi capek, lagi kangen, atau cuma pengen ada yang dengerin, buka aja yaa. Di sini ada Syra, ada hitungan kebersamaan, dan ada momen kecil yang disimpan buat Misra',
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
            const SizedBox(height: 14),
            Text(
              'Pilih yang Misra mau dulu yaa, semuanya dibuat buat nemenin kamu',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        isDark ? AppColors.darkMutedText : AppColors.mutedText,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 18),
            _HomeLoveCounterCard(
              days: days,
              hours: hours,
              minutes: minutes,
              seconds: seconds,
            ),
            const SizedBox(height: 16),
            MenuCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chat dengan Syra',
              subtitle: 'Kalau pengen cerita, Syra siap nemenin Misra yaa',
              onTap: () {
                Navigator.of(context).pushNamed(ChatPage.routeName);
              },
            ),
            const SizedBox(height: 14),
            MenuCard(
              icon: Icons.auto_stories_rounded,
              title: 'Timeline',
              subtitle: 'Buat lihat momen kecil yang tetap berarti',
              onTap: () {
                Navigator.of(context).pushNamed(TimelinePage.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeLoveCounterCard extends StatelessWidget {
  const _HomeLoveCounterCard({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceSoft.withValues(alpha: 0.9)
                  : AppColors.blush.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Love Counter',
              style: TextStyle(
                color: isDark ? AppColors.darkRose : AppColors.rose,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$days hari',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkRose : AppColors.rose,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Waktu kebersamaan kalian tetap jalan sampai sekarang',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      isDark ? AppColors.darkMutedText : AppColors.mutedText,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HomeCounterChip(label: 'Jam', value: hours),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HomeCounterChip(label: 'Menit', value: minutes),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HomeCounterChip(label: 'Detik', value: seconds),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeCounterChip extends StatelessWidget {
  const _HomeCounterChip({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.darkSurfaceSoft,
                  AppColors.darkBorder,
                ]
              : [
                  AppColors.blush,
                  AppColors.softPink.withValues(alpha: 0.95),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      isDark ? AppColors.darkMutedText : AppColors.mutedText,
                ),
          ),
        ],
      ),
    );
  }
}
