import 'package:flutter/material.dart';
import 'package:app/widgets/gradient_scaffold.dart';
import '../services/journal_entry_service.dart';

class JournalHomePage extends StatefulWidget {
  const JournalHomePage({Key? key}) : super(key: key);

  @override
  JournalHomePageState createState() => JournalHomePageState();
}

class JournalHomePageState extends State<JournalHomePage> {
  final JournalEntryService _journalService = JournalEntryService();
  final TextEditingController _controller = TextEditingController();
  List<String> _savedEntries = [];
  final Set<int> _expandedEntries = {};

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    final entries = await _journalService.loadEntries();

    if (!mounted) return;

    setState(() {
      _savedEntries = entries;
    });
  }

  Future<void> _saveEntry() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final entries = await _journalService.saveEntry(text);

    if (!mounted) return;

    setState(() {
      _savedEntries = entries;
    });

    _controller.clear();
  }

  Future<void> _deleteEntry(int index) async {
    final entries = await _journalService.deleteEntry(index);

    if (!mounted) return;

    setState(() {
      _savedEntries = entries;
      _expandedEntries.clear();
    });
  }

  ({String timestamp, String body}) _splitEntry(String entry) {
    final delimiter = entry.indexOf(':\n');
    if (delimiter == -1) {
      return (timestamp: '', body: entry);
    }
    return (
      timestamp: entry.substring(0, delimiter),
      body: entry.substring(delimiter + 2),
    );
  }

  String _formatTimestamp(String raw) {
    if (raw.isEmpty) return 'Saved entry';

    try {
      final date = DateTime.parse(raw);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final month = months[date.month - 1];
      final hour =
          date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final suffix = date.hour >= 12 ? 'PM' : 'AM';
      return '$month ${date.day}, ${date.year}  $hour:$minute $suffix';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardVisible = viewInsets.bottom > 0;
    final entriesPanelHeight = keyboardVisible ? 220.0 : screenHeight * 0.42;

    return GradientScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets.bottom),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A004D43),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    CircleAvatar(
                      backgroundColor: Color(0x220D9A86),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: Color(0xFF0D9A86),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'My Journal',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D5A50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText:
                            'Write your thoughts, wins, or reflections...',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saveEntry,
                        icon: const Icon(Icons.save_alt_rounded),
                        label: const Text('Save Entry'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Entries',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D5A50),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: entriesPanelHeight,
                child:
                    _savedEntries.isEmpty
                        ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.nights_stay_outlined,
                                size: 42,
                                color: Color(0xFF527D77),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No entries yet.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C4D49),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Start writing to build your journal timeline.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF486663)),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: _savedEntries.length,
                          itemBuilder: (context, index) {
                            final reverseIndex =
                                _savedEntries.length - 1 - index;
                            final rawEntry = _savedEntries[reverseIndex];
                            final parsed = _splitEntry(rawEntry);
                            final isExpanded = _expandedEntries.contains(
                              reverseIndex,
                            );

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xEAF9FFFD),
                                    Color(0xEBEBFAF7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x17004D43),
                                    blurRadius: 16,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedEntries.remove(reverseIndex);
                                      } else {
                                        _expandedEntries.add(reverseIndex);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      14,
                                      10,
                                      10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatTimestamp(parsed.timestamp),
                                          style: const TextStyle(
                                            color: Color(0xFF0D7E70),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          parsed.body,
                                          maxLines: isExpanded ? null : 3,
                                          overflow:
                                              isExpanded
                                                  ? TextOverflow.visible
                                                  : TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF2E4D49),
                                            height: 1.35,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton.filledTonal(
                                            onPressed:
                                                () =>
                                                    _deleteEntry(reverseIndex),
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                            ),
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
