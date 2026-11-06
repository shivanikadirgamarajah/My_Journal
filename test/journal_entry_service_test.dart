import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/journal_entry_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Can save and delete a journal entry', () async {
    final service = JournalEntryService();

    await service.saveEntry('Hello, journal!');

    final entries = await service.loadEntries();

    expect(entries.length, 1);
    expect(entries.first, contains('Hello, journal!'));

    await service.deleteEntry(0);

    final remaining = await service.loadEntries();

    expect(remaining, isEmpty);
  });
}
