import 'package:shared_preferences/shared_preferences.dart';

class JournalEntryService {
  static const String _key = 'entries';

  Future<List<String>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<List<String>> saveEntry(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await loadEntries();

    final newEntry = '${DateTime.now()}:\n${text.trim()}';
    entries.add(newEntry);

    await prefs.setStringList(_key, entries);

    return entries;
  }

  Future<List<String>> deleteEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await loadEntries();

    if (index < 0 || index >= entries.length) {
      throw RangeError.index(index, entries);
    }

    entries.removeAt(index);
    await prefs.setStringList(_key, entries);

    return entries;
  }
}
