import 'package:flutter/material.dart';

void main() {
  runApp(const GlobalTextColorApp());
}

class GlobalTextColorApp extends StatefulWidget {
  const GlobalTextColorApp({super.key});

  @override
  State<GlobalTextColorApp> createState() => _GlobalTextColorAppState();
}

class _GlobalTextColorAppState extends State<GlobalTextColorApp> {
  int _colorIndex = 0;
  static const List<Color> _palette = <Color>[
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  Color get _currentColor => _palette[_colorIndex % _palette.length];

  ThemeData _buildTheme(Color color) {
    final base = ThemeData.light();
    // Apply the color to the entire text theme
    final textTheme = base.textTheme.apply(
      bodyColor: color,
      displayColor: color,
      decorationColor: color,
    );
    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: textTheme.titleLarge?.copyWith(color: color),
        foregroundColor: color,
      ),
      colorScheme: base.colorScheme.copyWith(primary: color),
    );
  }

  void _nextColor() {
    setState(() {
      _colorIndex = (_colorIndex + 1) % _palette.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = _buildTheme(_currentColor);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        appBar: AppBar(title: const Text('Global Text Color Changer')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text('This is a headline', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Subtitle text goes here', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Body text example for demonstration'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _nextColor,
          label: const Text('Change Text Color'),
          icon: const Icon(Icons.format_color_text),
        ),
      ),
    );
  }
}


