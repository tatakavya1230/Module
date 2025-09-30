import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TwoColumnsPage(),
  ));
}

class TwoColumnsPage extends StatelessWidget {
  const TwoColumnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Two Columns')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // even spacing
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            _NameColumn(label: 'First Name'),
            _NameColumn(label: 'Last Name'),
          ],
        ),
      ),
    );
  }
}

class _NameColumn extends StatelessWidget {
  final String label;
  const _NameColumn({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


