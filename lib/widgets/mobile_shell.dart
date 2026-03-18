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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.darkBackground,
                        AppColors.darkSurface,
                        AppColors.darkSurfaceSoft,
                      ]
                    : [
                        AppColors.ivory,
                        AppColors.cream,
                        AppColors.blush,
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.darkRose : AppColors.softPink)
                    .withValues(alpha: isDark ? 0.12 : 0.28),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -90,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(56),
                  color: isDark
                      ? AppColors.darkSurfaceSoft.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.32),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.darkRose : AppColors.rose)
                    .withValues(alpha: isDark ? 0.12 : 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            left: 22,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? AppColors.darkBorder : AppColors.softPink)
                      .withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: SizedBox(
                      width: double.infinity,
                      height: constraints.maxHeight,
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : Container(
              color: isDark ? AppColors.darkBackground : AppColors.ivory,
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
