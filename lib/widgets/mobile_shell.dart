import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class MobileShell extends StatelessWidget {
  const MobileShell({
    super.key,
    required this.child,
    this.appBar,
    this.bottomBar,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.cream, AppColors.blush],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child,
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : Container(
              color: AppColors.cream,
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: bottomBar,
                  ),
                ),
              ),
            ),
    );
  }
}
