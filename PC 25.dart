import 'package:flutter/material.dart';

void main() {
  runApp(const EvenOddNumberApp());
}

class EvenOddNumberApp extends StatelessWidget {
  const EvenOddNumberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Even & Odd Numbers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const NumberListScreen(),
    );
  }
}

class NumberListScreen extends StatelessWidget {
  const NumberListScreen({super.key});

  // Hint 1: Declare the list inside the dart file
  static const List<int> numberList = [10, 12, 13, 56, 27, 29, 30];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Even & Odd Numbers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Number Classification',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Even numbers (divisible by 2) are shown in green\nOdd numbers (not divisible by 2) are shown in red',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  color: Colors.green,
                  label: 'Even Numbers',
                  icon: Icons.check_circle,
                ),
                _buildLegendItem(
                  color: Colors.red,
                  label: 'Odd Numbers',
                  icon: Icons.cancel,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // List title
            const Text(
              'Numbers List:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Hint 3: Add ListView.builder to show the data in the UI
            Expanded(
              child: ListView.builder(
                itemCount: numberList.length,
                itemBuilder: (context, index) {
                  final number = numberList[index];
                  // Hint 2: Use numberList[index]%2==0 to check if divided by 2
                  final isEven = number % 2 == 0;
                  
                  return _buildNumberItem(
                    number: number,
                    index: index,
                    isEven: isEven,
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    count: numberList.where((n) => n % 2 == 0).length,
                    label: 'Even Numbers',
                    color: Colors.green,
                  ),
                  _buildSummaryItem(
                    count: numberList.where((n) => n % 2 != 0).length,
                    label: 'Odd Numbers',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberItem({
    required int number,
    required int index,
    required bool isEven,
  }) {
    final Color itemBaseColor = isEven ? Colors.green : Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEven ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: itemBaseColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: itemBaseColor.withOpacity(0.1), // Fix: Use withOpacity for shadow color
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Index
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Number
          Expanded(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isEven ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
          ),
          
          // Status icon and text
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                isEven ? Icons.check_circle : Icons.cancel,
                color: itemBaseColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                isEven ? 'EVEN' : 'ODD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isEven ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Fix: Use withOpacity for legend item background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required int count,
    required String label,
    required MaterialColor color, // Changed type from Color to MaterialColor
  }) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color[700], // Access shade using [] operator
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}