import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persistent Text Storage Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PersistentTextScreen(),
    );
  }
}

class PersistentTextScreen extends StatefulWidget {
  const PersistentTextScreen({super.key});

  @override
  State<PersistentTextScreen> createState() => _PersistentTextScreenState();
}

class _PersistentTextScreenState extends State<PersistentTextScreen> {
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String _savedText = '';

  // Key for SharedPreferences
  static const String _textKey = 'saved_text';

  @override
  void initState() {
    super.initState();
    _loadSavedText();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Load saved text from SharedPreferences
  Future<void> _loadSavedText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedText = prefs.getString(_textKey) ?? '';
      
      setState(() {
        _savedText = savedText;
        _textController.text = savedText;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading saved text: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Save text to SharedPreferences
  Future<void> _saveText(String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_textKey, text);
      
      setState(() {
        _savedText = text;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving text: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Clear saved text
  Future<void> _clearText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_textKey);
      
      setState(() {
        _savedText = '';
        _textController.clear();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text cleared successfully!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing text: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persistent Text Storage'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _clearText,
            icon: const Icon(Icons.clear),
            tooltip: 'Clear saved text',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with instructions
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Persistent Text Storage Demo',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter text below and it will be automatically saved to local storage. When you reopen the app, your text will be restored.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // TextFormField
                    TextFormField(
                      controller: _textController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: 'Enter your text here',
                        hintText: 'Type something and it will be saved automatically...',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.edit),
                        suffixIcon: _textController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _textController.clear();
                                  _saveText('');
                                },
                                icon: const Icon(Icons.clear),
                                tooltip: 'Clear text',
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        // Auto-save as user types (with a small delay to avoid too frequent saves)
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_textController.text == value) {
                            _saveText(value);
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _saveText(_textController.text);
                              }
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Save Text'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _clearText,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear All'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Status information
                    if (_savedText.isNotEmpty)
                      Card(
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Text saved successfully! Character count: ${_savedText.length}',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
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
