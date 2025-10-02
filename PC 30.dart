import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SimpleTextFormFieldPage(),
  ));
}

class SimpleTextFormFieldPage extends StatefulWidget {
  const SimpleTextFormFieldPage({super.key});

  @override
  State<SimpleTextFormFieldPage> createState() => _SimpleTextFormFieldPageState();
}

class _SimpleTextFormFieldPageState extends State<SimpleTextFormFieldPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  String _savedValue = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _savedValue = _controller.text.trim();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved: $_savedValue')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple TextFormField')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter a value'
                    : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
              const SizedBox(height: 24),
              Text('Saved value: ${_savedValue.isEmpty ? '(none)' : _savedValue}'),
            ],
          ),
        ),
      ),
    );
  }
}


