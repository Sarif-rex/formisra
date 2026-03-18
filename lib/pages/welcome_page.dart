import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/mobile_shell.dart';
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
    return MobileShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.rose,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Untuk Misra',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Text(
                    'Web kecil ini aku bikin supaya kesayangan Syarif tetap punya tempat yang hangat buat pulang, meski aku nggak selalu bisa hadir di setiap waktu. Kalau kamu mau, masuk ya.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.text,
                          height: 1.6,
                        ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Dari Syarif, buat nemenin hari-hari Misra dengan cara yang sederhana.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedText,
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
