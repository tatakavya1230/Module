import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CounterResetModel(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CounterResetHomePage(),
      ),
    ),
  );
}

class CounterResetModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count += 1;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}

class CounterResetHomePage extends StatelessWidget {
  const CounterResetHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter with Reset'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display widget
            CounterDisplayWidget(),
            SizedBox(height: 40),
            // Control buttons
            CounterControlWidget(),
          ],
        ),
      ),
    );
  }
}

// Separate widget that displays the counter value
class CounterDisplayWidget extends StatelessWidget {
  const CounterDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterResetModel>(
      builder: (context, model, _) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade200, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.countertops,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                '${model.count}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Current Count',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Separate widget with control buttons
class CounterControlWidget extends StatelessWidget {
  const CounterControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterResetModel>(
      builder: (context, model, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Increment button
            ElevatedButton.icon(
              onPressed: model.increment,
              icon: const Icon(Icons.add),
              label: const Text('Increment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Reset button
            ElevatedButton.icon(
              onPressed: model.count > 0 ? model.reset : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
