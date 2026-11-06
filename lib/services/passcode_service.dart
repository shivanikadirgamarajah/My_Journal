import 'package:shared_preferences/shared_preferences.dart';

class PasscodeService {
  static const String _key = 'passcode';

  Future<String?> loadPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> savePasscode(String passcode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, passcode);
  }
}
