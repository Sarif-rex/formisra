import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/mobile_shell.dart';
import '../widgets/theme_toggle_button.dart';
import 'home_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  static const routeName = '/';

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _slideAnimation = Tween(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MobileShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.topRight,
                  child: ThemeToggleButton(),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              AppColors.darkSurface,
                              AppColors.darkSurfaceSoft,
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.96),
                              AppColors.blush.withValues(alpha: 0.9),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? AppColors.darkShadow : AppColors.shadow,
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceSoft
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: isDark ? AppColors.darkRose : AppColors.rose,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 18),
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
                          'Tempat kecil dari Syarif',
                          style: TextStyle(
                            color:
                                isDark ? AppColors.darkRose : AppColors.rose,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Untuk Misra',
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Web kecil ini aku bikin supaya Misrakuu sayang tetap punya tempat yang hangat buat pulang dan tetap merasa ditemenin',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.text,
                              height: 1.6,
                            ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Text(
                          'Di sini ada Syra, ada waktu kebersamaan kita, dan ada hal-hal kecil yang bisa Misrakuu buka kapan pun lagi pengen ditemenin',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.darkMutedText
                                        : AppColors.mutedText,
                                    height: 1.5,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Kalau mau, masuk aja yaa. Semuanya udah disiapin di sini buat nemenin kamu',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.mutedText,
                        height: 1.45,
                      ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(HomePage.routeName);
                  },
                  child: const Text('Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
