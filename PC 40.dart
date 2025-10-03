import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag & Drop Reorderable List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ReorderableListPage(),
    );
  }
}

class ReorderableListPage extends StatefulWidget {
  @override
  _ReorderableListPageState createState() => _ReorderableListPageState();
}

class _ReorderableListPageState extends State<ReorderableListPage> {
  // Initial list of items
  List<String> _items = [
    'item1',
    'item2', 
    'item3',
    'item4',
    'item5'
  ];

  // Additional items for demonstration
  List<String> _extendedItems = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew',
    'Kiwi',
    'Lemon'
  ];

  bool _useExtendedList = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Drag & Drop Reorderable List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetList,
            tooltip: 'Reset List',
          ),
          IconButton(
            icon: Icon(
              _useExtendedList ? Icons.list : Icons.list_alt,
              color: Colors.white,
            ),
            onPressed: _toggleListType,
            tooltip: _useExtendedList ? 'Switch to Simple List' : 'Switch to Extended List',
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'How to Use:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• Long press and drag any item to reorder\n'
                  '• Items will show visual feedback during drag\n'
                  '• Release to drop the item in the new position\n'
                  '• Use the refresh button to reset the list',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Reorderable List
          Expanded(
            child: _buildReorderableList(),
          ),
          
          // List Info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Items: ${_getCurrentList().length}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Current Order: ${_getCurrentList().join(', ')}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewItem,
        backgroundColor: Colors.blue[600],
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Item',
      ),
    );
  }

  Widget _buildReorderableList() {
    final currentList = _getCurrentList();
    
    return ReorderableListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: currentList.length,
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        final item = currentList[index];
        return _buildListItem(item, index);
      },
    );
  }

  Widget _buildListItem(String item, int index) {
    return Card(
      key: ValueKey(item), // Important: Each item needs a unique key
      margin: EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          item,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          'Position: ${index + 1}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Icon(
              Icons.drag_handle,
              color: Colors.grey[400],
              size: 20,
            ),
            SizedBox(width: 8),
            // Delete button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 20,
              ),
              onPressed: () => _deleteItem(item),
              tooltip: 'Delete Item',
            ),
          ],
        ),
        onTap: () => _showItemDetails(item, index),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      // Adjust newIndex for the case where the item is moved down
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      // Get the current list
      final currentList = _getCurrentList();
      
      // Remove the item from the old position
      final item = currentList.removeAt(oldIndex);
      
      // Insert the item at the new position
      currentList.insert(newIndex, item);
      
      // Update the appropriate list
      if (_useExtendedList) {
        _extendedItems = currentList;
      } else {
        _items = currentList;
      }
    });
  }

  void _resetList() {
    setState(() {
      if (_useExtendedList) {
        _extendedItems = [
          'Apple',
          'Banana',
          'Cherry',
          'Date',
          'Elderberry',
          'Fig',
          'Grape',
          'Honeydew',
          'Kiwi',
          'Lemon'
        ];
      } else {
        _items = [
          'item1',
          'item2',
          'item3',
          'item4',
          'item5'
        ];
      }
    });
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('List has been reset to original order'),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleListType() {
    setState(() {
      _useExtendedList = !_useExtendedList;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${_useExtendedList ? 'Extended' : 'Simple'} list'),
        backgroundColor: Colors.blue[600],
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addNewItem() {
    final currentList = _getCurrentList();
    final newItem = 'New Item ${currentList.length + 1}';
    
    setState(() {
      if (_useExtendedList) {
        _extendedItems.add(newItem);
      } else {
        _items.add(newItem);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added: $newItem'),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteItem(String item) {
    setState(() {
      if (_useExtendedList) {
        _extendedItems.remove(item);
      } else {
        _items.remove(item);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: $item'),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showItemDetails(String item, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Item Details',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Item Name', item),
              _buildDetailRow('Position', '${index + 1}'),
              _buildDetailRow('List Type', _useExtendedList ? 'Extended' : 'Simple'),
              _buildDetailRow('Total Items', '${_getCurrentList().length}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: Colors.blue[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(item);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getCurrentList() {
    return _useExtendedList ? _extendedItems : _items;
  }
}
