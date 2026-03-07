import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const JournalApp());
}

class JournalApp extends StatelessWidget {
  const JournalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Journal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9A86),
          brightness: Brightness.light,
        ),
        fontFamily: 'Georgia',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.92),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF8FD6CA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF8FD6CA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0D9A86), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      home: const PasscodeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({Key? key}) : super(key: key);

  @override
  _PasscodeScreenState createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  final TextEditingController _passcodeController = TextEditingController();
  String? _storedPasscode;
  String? _errorText;
  bool _isSettingPasscode = false;

  @override
  void initState() {
    super.initState();
    _loadPasscode();
  }

  void _loadPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('passcode');
    setState(() {
      _storedPasscode = stored;
      _isSettingPasscode = stored == null;
    });
  }

  void _handlePasscode() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isSettingPasscode) {
      if (_passcodeController.text.length < 4) {
        setState(() {
          _errorText = 'Passcode must be at least 4 digits.';
        });
        return;
      }
      await prefs.setString('passcode', _passcodeController.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JournalHomePage()),
      );
    } else {
      if (_passcodeController.text == _storedPasscode) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JournalHomePage()),
        );
      } else {
        setState(() {
          _errorText = 'Incorrect passcode. Please try again!';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2B0D9A86),
                    blurRadius: 30,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0x220D9A86),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 28,
                      color: Color(0xFF0D9A86),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isSettingPasscode
                        ? 'Create your journal passcode'
                        : 'Welcome back to your journal',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Color(0xFF0D5A50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isSettingPasscode
                        ? 'Set a secure passcode to keep your entries private.'
                        : 'Enter your passcode to unlock your entries.',
                    style: const TextStyle(
                      color: Color(0xFF486663),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _passcodeController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Passcode',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    onSubmitted: (_) => _handlePasscode(),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child:
                        _errorText == null
                            ? const SizedBox(height: 20)
                            : Padding(
                              key: ValueKey(_errorText),
                              padding: const EdgeInsets.only(top: 2, left: 4),
                              child: Text(
                                _errorText!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _handlePasscode,
                      icon: Icon(
                        _isSettingPasscode
                            ? Icons.shield_outlined
                            : Icons.lock_open_rounded,
                      ),
                      label: Text(
                        _isSettingPasscode ? 'Set Passcode' : 'Unlock Journal',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class JournalHomePage extends StatefulWidget {
  const JournalHomePage({Key? key}) : super(key: key);

  @override
  JournalHomePageState createState() => JournalHomePageState();
}

class JournalHomePageState extends State<JournalHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _savedEntries = [];
  final Set<int> _expandedEntries = {};

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  void _loadEntry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedEntries = prefs.getStringList('entries') ?? [];
    });
  }

  void _saveEntry() async {
    if (_controller.text.trim().isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> entries = prefs.getStringList('entries') ?? [];
    final newEntry =
        '${DateTime.now().toString()}:\n${_controller.text.trim()}';
    entries.add(newEntry);
    await prefs.setStringList('entries', entries);
    setState(() {
      _savedEntries = entries;
    });
    _controller.clear();
  }

  void _deleteEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedEntries.removeAt(index);
    });
    await prefs.setStringList('entries', _savedEntries);
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

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFCFF8EC), Color(0xFF9FE5D8), Color(0xFFCCE6FF)],
          ),
        ),
        child: child,
      ),
    );
  }
}
