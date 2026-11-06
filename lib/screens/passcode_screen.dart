import 'package:flutter/material.dart';
import '../services/passcode_service.dart';
import '../widgets/gradient_scaffold.dart';
import 'journal_home_page.dart';

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({Key? key}) : super(key: key);

  @override
  _PasscodeScreenState createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  final PasscodeService _passcodeService = PasscodeService();
  final TextEditingController _passcodeController = TextEditingController();
  String? _storedPasscode;
  String? _errorText;
  bool _isSettingPasscode = false;

  @override
  void initState() {
    super.initState();
    _loadPasscode();
  }

  Future<void> _loadPasscode() async {
    final stored = await _passcodeService.loadPasscode();

    if (!mounted) return;

    setState(() {
      _storedPasscode = stored;
      _isSettingPasscode = stored == null;
    });
  }

  void _handlePasscode() async {
    if (_isSettingPasscode) {
      if (_passcodeController.text.length < 4) {
        setState(() {
          _errorText = 'Passcode must be at least 4 digits.';
        });
        return;
      }
      await _passcodeService.savePasscode(_passcodeController.text);
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
