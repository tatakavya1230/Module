import 'package:flutter/material.dart';

void main() {
  runApp(const SharedCounterApp());
}

class SharedCounterApp extends StatefulWidget {
  const SharedCounterApp({super.key});

  @override
  State<SharedCounterApp> createState() => _SharedCounterAppState();
}

class _SharedCounterAppState extends State<SharedCounterApp> {
  // Shared state: accessible to both screens
  final ValueNotifier<int> counter = ValueNotifier<int>(0);

  @override
  void dispose() {
    counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Two Screens Shared Counter',
      routes: {
        '/': (_) => HomeScreen(counter: counter),
        '/second': (_) => SecondScreen(counter: counter),
      },
      initialRoute: '/',
    );
  }
}

class HomeScreen extends StatelessWidget {
  final ValueNotifier<int> counter;
  const HomeScreen({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home value:'),
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: counter,
              builder: (_, value, __) => Text(
                '$value',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/second'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Go to Second Screen'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => counter.value += 1,
        icon: const Icon(Icons.add),
        label: const Text('Increment Both'),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  final ValueNotifier<int> counter;
  const SecondScreen({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Second screen value:'),
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: counter,
              builder: (_, value, __) => Text(
                '$value',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}


