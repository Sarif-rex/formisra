import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/greeting_service.dart';
import '../widgets/app_card.dart';
import '../widgets/menu_card.dart';
import '../widgets/mobile_shell.dart';
import 'chat_page.dart';
import 'love_counter_page.dart';
import 'timeline_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final greeting = GreetingService.forCurrentTime(DateTime.now());

    return MobileShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, sayang',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              greeting,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.mutedText,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 22),
            const AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selalu ada ruang kecil buat kamu di sini.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Kalau lagi pengen ditemenin, pengen lihat hitungan kebersamaan, atau cuma mau baca momen sederhana kalian, tinggal pilih aja.',
                    style: TextStyle(
                      color: AppColors.mutedText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            MenuCard(
              icon: Icons.favorite_border_rounded,
              title: 'Love Counter',
              subtitle: 'Lihat hitungan hari, jam, menit, dan detik sejak 1 November 2024.',
              onTap: () {
                Navigator.of(context).pushNamed(LoveCounterPage.routeName);
              },
            ),
            const SizedBox(height: 14),
            MenuCard(
              icon: Icons.auto_stories_rounded,
              title: 'Timeline',
              subtitle: 'Momen sederhana yang bisa terus ditambah nanti.',
              onTap: () {
                Navigator.of(context).pushNamed(TimelinePage.routeName);
              },
            ),
            const SizedBox(height: 14),
            MenuCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chat dengan Syra',
              subtitle: 'Tempat ngobrol hangat saat kamu pengen ditemenin.',
              onTap: () {
                Navigator.of(context).pushNamed(ChatPage.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
