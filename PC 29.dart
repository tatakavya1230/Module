import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MoveWidgetDemo(),
  ));
}

class MoveWidgetDemo extends StatefulWidget {
  const MoveWidgetDemo({super.key});

  @override
  State<MoveWidgetDemo> createState() => _MoveWidgetDemoState();
}

class _MoveWidgetDemoState extends State<MoveWidgetDemo> {
  // Start at top-left
  Alignment _alignment = Alignment.topLeft;

  void _toggleAlignment() {
    setState(() {
      _alignment = _alignment == Alignment.topLeft
          ? Alignment.bottomRight
          : Alignment.topLeft;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Move Widget with AnimatedAlign')),
      body: Stack(
        children: [
          // Hint 2: Use Align/AnimatedAlign to move
          AnimatedAlign(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            alignment: _alignment,
            child: _buildMovable(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleAlignment,
        label: const Text('Move'),
        icon: const Icon(Icons.open_with),
      ),
    );
  }

  // Hint 1: Use an image or container as the moving widget
  Widget _buildMovable() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.directions_run, color: Colors.white, size: 48),
    );
  }
}


