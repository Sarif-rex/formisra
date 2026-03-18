import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'pages/chat_page.dart';
import 'pages/home_page.dart';
import 'pages/love_counter_page.dart';
import 'pages/timeline_page.dart';
import 'pages/welcome_page.dart';

class FormisraApp extends StatelessWidget {
  const FormisraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Untuk Misra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: WelcomePage.routeName,
      routes: {
        WelcomePage.routeName: (_) => const WelcomePage(),
        HomePage.routeName: (_) => const HomePage(),
        LoveCounterPage.routeName: (_) => const LoveCounterPage(),
        TimelinePage.routeName: (_) => const TimelinePage(),
        ChatPage.routeName: (_) => const ChatPage(),
      },
    );
  }
}
