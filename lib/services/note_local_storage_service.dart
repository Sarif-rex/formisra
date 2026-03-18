import 'package:shared_preferences/shared_preferences.dart';

class NoteLocalStorageService {
  const NoteLocalStorageService();

  static const _noteTextKey = 'misra_note_text';
  static const _noteUpdatedAtKey = 'misra_note_updated_at';

  Future<String> loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_noteTextKey) ?? '';
  }

  Future<DateTime?> loadUpdatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_noteUpdatedAtKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<void> saveNote(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_noteTextKey, text);
    await prefs.setString(
      _noteUpdatedAtKey,
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> clearNote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_noteTextKey);
    await prefs.remove(_noteUpdatedAtKey);
  }
}
