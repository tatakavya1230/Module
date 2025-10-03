import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => StringListModel(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StringListHomePage(),
      ),
    ),
  );
}

class StringListModel extends ChangeNotifier {
  final List<String> _items = [];

  List<String> get items => List.unmodifiable(_items);

  void addString(String newString) {
    if (newString.trim().isNotEmpty) {
      _items.add(newString.trim());
      notifyListeners();
    }
  }

  void removeString(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }
}

class StringListHomePage extends StatefulWidget {
  const StringListHomePage({super.key});

  @override
  State<StringListHomePage> createState() => _StringListHomePageState();
}

class _StringListHomePageState extends State<StringListHomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addString() {
    final text = _controller.text;
    if (text.trim().isNotEmpty) {
      context.read<StringListModel>().addString(text);
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('String List Provider'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter a string',
                      border: OutlineInputBorder(),
                      hintText: 'Type something...',
                    ),
                    onSubmitted: (_) => _addString(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addString,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // List display section
            const Expanded(
              child: StringListView(),
            ),
          ],
        ),
      ),
    );
  }
}

// Separate widget that displays the list
class StringListView extends StatelessWidget {
  const StringListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StringListModel>(
      builder: (context, model, _) {
        if (model.items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.list_alt,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No items yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add some strings to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items (${model.items.length}):',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: model.items.length,
                itemBuilder: (context, index) {
                  final item = model.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        item,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => model.removeString(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Remove item',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
