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
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const PasscodeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PasscodeScreen extends StatefulWidget{
  const PasscodeScreen({Key? key}) : super(key: key);

  @override
  _PasscodeScreenState createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen>{
  final TextEditingController _passcodeController = TextEditingController();
  String? _storedPasscode;
  String? _errorText;
  bool _isSettingPasscode = false;

  @override
  void initState(){
    super.initState();
    _loadPasscode();
  }

  void _loadPasscode() async {
    SharedPreferences prefs= await SharedPreferences.getInstance();
    String? stored= prefs.getString('passcode');
    setState(() {
      _storedPasscode=stored;
      _isSettingPasscode=stored==null;
    });
  }

  void _handlePasscode() async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    if (_isSettingPasscode){
      if(_passcodeController.text.length<4){
        setState(() {
          _errorText='Passcode must be at least 4 digits.';
        });
        return;
      }
      await prefs.setString('passcode', _passcodeController.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JournalHomePage()),

      );
    }else{
      if(_passcodeController.text==_storedPasscode){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context)=>const JournalHomePage()),

        );
      }else{
        if(_passcodeController.text==_storedPasscode){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context)=>const JournalHomePage()),
          );
        }else{
          setState(() {
            _errorText='Incorrect passcode. Please try again!';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSettingPasscode ? 'Create Password' : 'Enter Passcode'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passcodeController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Passcode',
                errorText: _errorText,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _handlePasscode(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handlePasscode,
              child: Text(_isSettingPasscode ? 'Set Password' : 'Unlock'),
            ),
          ],
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
  TextEditingController _controller = TextEditingController();
  List<String> _savedEntries = [];
  Set<int> _expandedEntries = {};

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> entries = prefs.getStringList('entries') ?? [];
    String newEntry = '${DateTime.now().toString()}:\n${_controller.text}';
    entries.add(newEntry);
    await prefs.setStringList('entries', entries);
    setState(() {
      _savedEntries = entries;
    });
    _controller.clear();
  }

  void _deleteEntry(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedEntries.removeAt(index);
    });
    await prefs.setStringList('entries', _savedEntries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Journal',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your journal entry...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _saveEntry, child: Text('Save Entry')),
            SizedBox(height: 20),
            Text(
              'Previous Entry:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child:
              _savedEntries.isEmpty
                  ? Text('No entries yet.')
                  : ListView.builder(
                itemCount: _savedEntries.length,
                itemBuilder: (context, index) {
                  final reverseIndex = _savedEntries.length - 1 - index;
                  final entry = _savedEntries[reverseIndex];
                  final isExpanded = _expandedEntries.contains(
                    reverseIndex,
                  );
                  final maxLines = isExpanded ? null : 3;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
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
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry,
                              maxLines: maxLines,
                              overflow:
                              isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _deleteEntry(reverseIndex),
                              ),
                            ),
                          ],
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
    );
  }
}
