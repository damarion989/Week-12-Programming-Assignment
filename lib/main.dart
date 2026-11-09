import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// Handles reading and writing the note file.
class NoteStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/notes.txt');
  }

  Future<void> writeNote(String text) async {
    final file = await _localFile;
    await file.writeAsString(text);
  }

  Future<String> readRawContent() async {
    final file = await _localFile;
    return await file.readAsString();
  }

  Future<String> readNote() async {
    try {
      final file = await _localFile;
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _isLoading = true;
  bool _isSaving = false;

  String _savedNote = '';
  String _status = '';

  final TextEditingController _noteController = TextEditingController();
  final NoteStorage _storage = NoteStorage();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Restore the theme and note when the app starts.
  Future<void> _loadData() async {
    bool darkMode = false;
    String status = '';

    try {
      final prefs = await SharedPreferences.getInstance();
      darkMode = prefs.getBool('isDarkMode') ?? false;
    } catch (e) {
      status = 'Could not load the saved theme.';
    }

    final note = await _storage.readNote();

    if (!mounted) return;

    setState(() {
      _isDarkMode = darkMode;
      _savedNote = note;
      _noteController.text = note;
      _status = status;
      _isLoading = false;
    });
  }

  // Change the theme immediately, then save the setting.
  Future<void> _updateTheme(bool newValue) async {
    setState(() {
      _isDarkMode = newValue;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setBool('isDarkMode', newValue);

      if (!mounted) return;

      setState(() {
        if (saved) {
          _status = 'Theme saved!';
        } else {
          _status = 'Could not save the theme.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = 'Could not save the theme.';
      });
    }
  }

  // Save the text and update the displayed note.
  Future<void> _saveNote() async {
    final text = _noteController.text;

    setState(() {
      _isSaving = true;
    });

    try {
      await _storage.writeNote(text);

      if (!mounted) return;

      setState(() {
        _savedNote = text;
        _status = 'Note saved to disk!';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = 'Could not save the note.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Read the saved file and print it to the console.
  Future<void> _printFile() async {
    try {
      final text = await _storage.readRawContent();
      debugPrint('Saved file contents:\n$text');

      if (!mounted) return;

      setState(() {
        _status = 'File printed to the debug console.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = 'Could not read the file. Try saving a note first.';
      });
    }
  }

  // Read the note again and show it in the app.
  Future<void> _readNote() async {
    final note = await _storage.readNote();

    if (!mounted) return;

    setState(() {
      _savedNote = note;
      _noteController.text = note;
      _status = 'Finished reading the note.';
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My Notes'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: _isDarkMode,
                      onChanged: (bool newValue) {
                        _updateTheme(newValue);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _noteController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Type your notes here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveNote,
                      child: const Text('Save Note'),
                    ),
                    OutlinedButton(
                      onPressed: _printFile,
                      child: const Text('Print File to Console'),
                    ),
                    OutlinedButton(
                      onPressed: _isSaving ? null : _readNote,
                      child: const Text('Read Saved Note'),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 24),
                    const Text(
                      'Saved Note:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _savedNote.isEmpty
                              ? 'No notes saved yet.'
                              : _savedNote,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
