import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TimerGifPage(),
  ));
}

class TimerGifPage extends StatefulWidget {
  const TimerGifPage({super.key});

  @override
  State<TimerGifPage> createState() => _TimerGifPageState();
}

class _TimerGifPageState extends State<TimerGifPage> {
  // Hint 2: flag to control rendering
  bool _showGif = true;

  @override
  void initState() {
    super.initState();
    // Hint 1: use Future.delayed for 15s
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() => _showGif = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Running Timer GIF')),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _showGif
              ? _buildGifView()
              : _buildTimeOverView(),
        ),
      ),
    );
  }

  // Render GIF (from assets or network fallback)
  Widget _buildGifView() {
    return Container(
      key: const ValueKey('gif'),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Try to load from assets; instruct user to add asset
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              // Placeholder network GIF of a running person
              'https://media.tenor.com/V4rQG2V1o-AAAAAC/running.gif',
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                return Container(
                  height: 220,
                  width: 220,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.movie, size: 48, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Running... (15s)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOverView() {
    return Container(
      key: const ValueKey('over'),
      padding: const EdgeInsets.all(24),
      child: const Text(
        'Running time has been over.',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}


