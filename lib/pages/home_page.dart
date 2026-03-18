import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/greeting_service.dart';
import '../widgets/app_card.dart';
import '../widgets/menu_card.dart';
import '../widgets/mobile_shell.dart';
import '../widgets/theme_toggle_button.dart';
import 'chat_page.dart';
import 'love_counter_page.dart';
import 'timeline_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final greeting = GreetingService.forCurrentTime(DateTime.now());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MobileShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceSoft.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Text(
                    'Tempat kecil dari Syarif',
                    style: TextStyle(
                      color: isDark ? AppColors.darkRose : AppColors.rose,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                const ThemeToggleButton(),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Halo, kesayangan Syarif',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              greeting,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        isDark ? AppColors.darkMutedText : AppColors.mutedText,
                    height: 1.45,
                  ),
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
                    offset: Offset(0, 12),
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
            const SizedBox(height: 12),
            Text(
              'Pilih yang Misra mau dulu yaa, semuanya dibuat buat nemenin kamu',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        isDark ? AppColors.darkMutedText : AppColors.mutedText,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 20),
            MenuCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chat dengan Syra',
              subtitle: 'Kalau pengen cerita, Syra siap nemenin Misra yaa',
              onTap: () {
                Navigator.of(context).pushNamed(ChatPage.routeName);
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MiniHomeCard(
                    icon: Icons.favorite_border_rounded,
                    title: 'Love Counter',
                    subtitle: 'Buat lihat waktu yang terus jalan bareng yaa',
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        LoveCounterPage.routeName,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniHomeCard(
                    icon: Icons.auto_stories_rounded,
                    title: 'Timeline',
                    subtitle: 'Buat lihat momen kecil yang tetap berarti yaa',
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        TimelinePage.routeName,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniHomeCard extends StatelessWidget {
  const _MiniHomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceSoft
                      : AppColors.blush,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isDark ? AppColors.darkRose : AppColors.rose,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkMutedText
                          : AppColors.mutedText,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
