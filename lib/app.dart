import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'pages/chat_page.dart';
import 'pages/home_page.dart';
import 'pages/love_counter_page.dart';
import 'pages/timeline_page.dart';
import 'pages/welcome_page.dart';
import 'services/theme_preferences_service.dart';

class FormisraApp extends StatefulWidget {
  const FormisraApp({super.key});

  static const String buildMarker = String.fromEnvironment(
    'BUILD_MARKER',
    defaultValue: 'LOCAL',
  );

  static _FormisraAppState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_FormisraAppState>();
    assert(state != null, 'FormisraApp state not found in widget tree.');
    return state!;
  }

  @override
  State<FormisraApp> createState() => _FormisraAppState();
}

class _FormisraAppState extends State<FormisraApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode = await ThemePreferencesService.loadThemeMode();
    if (!mounted) {
      return;
    }
    setState(() {
      _themeMode = mode;
    });
  }

  Future<void> toggleTheme() async {
    final nextMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setState(() {
      _themeMode = nextMode;
    });
    await ThemePreferencesService.saveThemeMode(nextMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Untuk Misra ${FormisraApp.buildMarker}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
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
