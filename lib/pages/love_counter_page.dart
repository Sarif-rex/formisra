import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/mobile_shell.dart';

class LoveCounterPage extends StatefulWidget {
  const LoveCounterPage({super.key});

  static const routeName = '/love-counter';

  @override
  State<LoveCounterPage> createState() => _LoveCounterPageState();
}

class _LoveCounterPageState extends State<LoveCounterPage> {
  static final DateTime _startedAt = DateTime(2024, 11, 1);

  late Timer _timer;
  Duration _duration = DateTime.now().difference(_startedAt);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
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
    final days = _duration.inDays;
    final hours = _duration.inHours.remainder(24);
    final minutes = _duration.inMinutes.remainder(60);
    final seconds = _duration.inSeconds.remainder(60);

    return MobileShell(
      appBar: AppBar(title: const Text('Love Counter')),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sejak 1 November 2024',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.mutedText,
                  ),
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                children: [
                  Text(
                    '$days hari',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.rose,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Waktu kebersamaan yang terus jalan, pelan tapi nyata.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedText,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(child: _CounterBox(label: 'Jam', value: hours)),
                      const SizedBox(width: 12),
                      Expanded(child: _CounterBox(label: 'Menit', value: minutes)),
                      const SizedBox(width: 12),
                      Expanded(child: _CounterBox(label: 'Detik', value: seconds)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterBox extends StatelessWidget {
  const _CounterBox({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedText,
                ),
          ),
        ],
      ),
    );
  }
}
