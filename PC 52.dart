import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CounterApp(),
    ),
  );
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MVVM Counter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CounterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==================== MODEL ====================
class CounterModel {
  final int value;
  final List<int> history;
  final DateTime lastUpdated;

  const CounterModel({
    required this.value,
    required this.history,
    required this.lastUpdated,
  });

  CounterModel copyWith({
    int? value,
    List<int>? history,
    DateTime? lastUpdated,
  }) {
    return CounterModel(
      value: value ?? this.value,
      history: history ?? this.history,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'history': history,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(
      value: json['value'] ?? 0,
      history: List<int>.from(json['history'] ?? []),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        json['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CounterModel &&
        other.value == value &&
        other.history.length == history.length &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => Object.hash(value, history, lastUpdated);
}

// ==================== VIEWMODEL ====================
class CounterViewModel extends StateNotifier<CounterModel> {
  CounterViewModel() : super(_initialState) {
    _loadFromStorage();
  }

  static const CounterModel _initialState = CounterModel(
    value: 0,
    history: [],
    lastUpdated: null,
  );

  // Private method to load data from SharedPreferences
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final counterData = prefs.getString('counter_data');
      
      if (counterData != null) {
        final Map<String, dynamic> jsonData = 
            Map<String, dynamic>.from(
              Uri.splitQueryString(counterData)
            );
        final model = CounterModel.fromJson(jsonData);
        state = model;
      } else {
        // Initialize with current timestamp
        state = state.copyWith(lastUpdated: DateTime.now());
      }
    } catch (e) {
      // If loading fails, use default state
      state = state.copyWith(lastUpdated: DateTime.now());
    }
  }

  // Private method to save data to SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = state.toJson();
      final queryString = Uri(queryParameters: jsonData.map(
        (key, value) => MapEntry(key, value.toString()),
      )).query;
      await prefs.setString('counter_data', queryString);
    } catch (e) {
      // Handle save error silently or show a snackbar
      debugPrint('Error saving counter data: $e');
    }
  }

  // Increment counter
  void increment() {
    final newValue = state.value + 1;
    final newHistory = [...state.history, newValue];
    
    state = state.copyWith(
      value: newValue,
      history: newHistory,
      lastUpdated: DateTime.now(),
    );
    
    _saveToStorage();
  }

  // Decrement counter
  void decrement() {
    final newValue = state.value - 1;
    final newHistory = [...state.history, newValue];
    
    state = state.copyWith(
      value: newValue,
      history: newHistory,
      lastUpdated: DateTime.now(),
    );
    
    _saveToStorage();
  }

  // Reset counter
  void reset() {
    state = state.copyWith(
      value: 0,
      history: [...state.history, 0],
      lastUpdated: DateTime.now(),
    );
    
    _saveToStorage();
  }

  // Clear history
  void clearHistory() {
    state = state.copyWith(
      history: [],
      lastUpdated: DateTime.now(),
    );
    
    _saveToStorage();
  }

  // Get counter statistics
  Map<String, dynamic> getStatistics() {
    if (state.history.isEmpty) {
      return {
        'max': 0,
        'min': 0,
        'average': 0.0,
        'totalOperations': 0,
      };
    }

    final max = state.history.reduce((a, b) => a > b ? a : b);
    final min = state.history.reduce((a, b) => a < b ? a : b);
    final sum = state.history.fold(0, (a, b) => a + b);
    final average = sum / state.history.length;

    return {
      'max': max,
      'min': min,
      'average': average,
      'totalOperations': state.history.length,
    };
  }
}

// ==================== PROVIDERS ====================
final counterProvider = StateNotifierProvider<CounterViewModel, CounterModel>(
  (ref) => CounterViewModel(),
);

final counterStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final counterViewModel = ref.watch(counterProvider.notifier);
  return counterViewModel.getStatistics();
});

// ==================== VIEW ====================
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    final statistics = ref.watch(counterStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MVVM Counter App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              _showStatisticsDialog(context, statistics);
            },
            icon: const Icon(Icons.analytics),
            tooltip: 'View Statistics',
          ),
          IconButton(
            onPressed: () {
              _showHistoryDialog(context, ref);
            },
            icon: const Icon(Icons.history),
            tooltip: 'View History',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Counter display
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[400]!,
                      Colors.blue[600]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${counter.value}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Counter value with styling
              Text(
                'Current Count',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${counter.value}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: counter.value >= 0 ? Colors.green[700] : Colors.red[700],
                ),
              ),

              const SizedBox(height: 40),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decrement button
                  FloatingActionButton(
                    onPressed: () {
                      ref.read(counterProvider.notifier).decrement();
                    },
                    heroTag: 'decrement',
                    backgroundColor: Colors.red[400],
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),

                  // Reset button
                  FloatingActionButton(
                    onPressed: () {
                      _showResetDialog(context, ref);
                    },
                    heroTag: 'reset',
                    backgroundColor: Colors.orange[400],
                    child: const Icon(Icons.refresh, color: Colors.white),
                  ),

                  // Increment button
                  FloatingActionButton(
                    onPressed: () {
                      ref.read(counterProvider.notifier).increment();
                    },
                    heroTag: 'increment',
                    backgroundColor: Colors.green[400],
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Additional info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Last Updated',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(counter.lastUpdated),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Operations: ${statistics['totalOperations']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showStatisticsDialog(BuildContext context, Map<String, dynamic> statistics) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Counter Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Maximum Value', '${statistics['max']}'),
            _buildStatRow('Minimum Value', '${statistics['min']}'),
            _buildStatRow('Average Value', '${statistics['average'].toStringAsFixed(2)}'),
            _buildStatRow('Total Operations', '${statistics['totalOperations']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Counter History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: counter.history.isEmpty
              ? const Center(
                  child: Text('No history available'),
                )
              : ListView.builder(
                  itemCount: counter.history.length,
                  itemBuilder: (context, index) {
                    final value = counter.history[index];
                    final isCurrent = index == counter.history.length - 1;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCurrent ? Colors.blue : Colors.grey,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        'Value: $value',
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.arrow_forward, color: Colors.blue)
                          : null,
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(counterProvider.notifier).clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear History'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Counter'),
        content: const Text('Are you sure you want to reset the counter to 0?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(counterProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
