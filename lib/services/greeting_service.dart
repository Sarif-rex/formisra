class GreetingService {
  const GreetingService._();

  static String forCurrentTime(DateTime now) {
    final hour = now.hour;
    if (hour < 11) {
      return 'Selamat pagi, kesayangan Syarif. Semoga harimu lembut dan ringan ya.';
    }
    if (hour < 17) {
      return 'Halo kesayangan Syarif, semoga hari ini tetap jalan dengan tenang buat kamu.';
    }
    if (hour < 21) {
      return 'Selamat malam, kesayangan Syarif. Kalau capek, pelan-pelan aja ya.';
    }
    return 'Malam, kesayangan Syarif. Semoga istirahatmu nanti nyaman dan hangat.';
  }
}
