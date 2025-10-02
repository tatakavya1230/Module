import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FormDataModel(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ProviderFormPage(),
      ),
    ),
  );
}

class FormDataModel extends ChangeNotifier {
  String _first = '';
  String _second = '';

  String get first => _first;
  String get second => _second;

  void submit(String firstValue, String secondValue) {
    _first = firstValue;
    _second = secondValue;
    notifyListeners();
  }
}

class ProviderFormPage extends StatefulWidget {
  const ProviderFormPage({super.key});

  @override
  State<ProviderFormPage> createState() => _ProviderFormPageState();
}

class _ProviderFormPageState extends State<ProviderFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<FormDataModel>().submit(
            _firstController.text.trim(),
            _secondController.text.trim(),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted')),
      );
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Form Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstController,
                    decoration: const InputDecoration(
                      labelText: 'First Value',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter the first value'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _secondController,
                    decoration: const InputDecoration(
                      labelText: 'Second Value',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter the second value'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onSubmit,
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Submitted Data:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const SubmittedDataView(),
          ],
        ),
      ),
    );
  }
}

// Widget consuming Provider data
class SubmittedDataView extends StatelessWidget {
  const SubmittedDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FormDataModel>(
      builder: (context, model, _) {
        final hasData = model.first.isNotEmpty || model.second.isNotEmpty;
        if (!hasData) {
          return const Text('No data submitted yet');
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('First: ${model.first}'),
              const SizedBox(height: 6),
              Text('Second: ${model.second}'),
            ],
          ),
        );
      },
    );
  }
}


