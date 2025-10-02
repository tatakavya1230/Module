import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CounterModel(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CounterHomePage(),
      ),
    ),
  );
}

class CounterModel extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count += 1;
    notifyListeners();
  }
}

class CounterHomePage extends StatelessWidget {
  const CounterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Counter')),
      body: const Center(child: CounterValueView()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterModel>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Separate widget that listens to the provider and displays the value
class CounterValueView extends StatelessWidget {
  const CounterValueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterModel>(
      builder: (context, model, _) => Text(
        'Count: ${model.count}',
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }
}


