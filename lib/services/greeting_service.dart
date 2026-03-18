class GreetingService {
  const GreetingService._();

  static String forCurrentTime(DateTime now) {
    final hour = now.hour;
    if (hour < 11) {
      return 'Selamat pagi, sayang. Semoga harimu lembut dan ringan ya.';
    }
    if (hour < 17) {
      return 'Halo sayang, semoga hari ini tetap jalan dengan tenang buat kamu.';
    }
    if (hour < 21) {
      return 'Selamat malam, sayang. Kalau capek, pelan-pelan aja ya.';
    }
    return 'Malam sayang, semoga istirahatmu nanti nyaman dan hangat.';
  }
}
