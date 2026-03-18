import '../models/timeline_entry.dart';

class TimelineData {
  const TimelineData._();

  static final items = <TimelineEntry>[
    TimelineEntry(
      title: 'Hari kita mulai',
      description: 'Tanggal yang bikin semuanya terasa lebih berarti.',
      date: DateTime(2024, 11, 1),
    ),
    TimelineEntry(
      title: 'Web kecil ini dibuat',
      description: 'Tempat sederhana supaya Syra bisa nemenin Misra kapan pun dibuka.',
      date: DateTime(2026, 3, 16),
    ),
  ];
}
