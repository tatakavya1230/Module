import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic List Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DynamicListPage(),
    );
  }
}

class DynamicListPage extends StatefulWidget {
  @override
  _DynamicListPageState createState() => _DynamicListPageState();
}

class _DynamicListPageState extends State<DynamicListPage> {
  // Initial data list as provided
  List<String> _data = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
  ];

  // Counter for generating new item names
  int _itemCounter = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Dynamic List Management',
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
                  '• Tap any item to select it\n'
                  '• Use the "Add Item" button to add a new item\n'
                  '• Use the "Delete" button to remove selected item\n'
                  '• Use "Add to List" to add selected item to the list',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Selected Item Display
          if (_selectedItem != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Selected: $_selectedItem',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: _clearSelection,
                    child: Text(
                      'Clear',
                      style: TextStyle(color: Colors.green[600]),
                    ),
                  ),
                ],
              ),
            ),
          
          // Action Buttons
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _addNewItem,
                  icon: Icon(Icons.add),
                  label: Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _selectedItem != null ? _deleteSelectedItem : null,
                  icon: Icon(Icons.delete),
                  label: Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _selectedItem != null ? _addSelectedToData : null,
                  icon: Icon(Icons.add_to_photos),
                  label: Text('Add to List'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          
          // List Display
          Expanded(
            child: _buildList(),
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
                  'Total Items: ${_data.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Next Item: Item $_itemCounter',
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
    );
  }

  String? _selectedItem;

  Widget _buildList() {
    if (_data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No Items in List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add some items to get started',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _data.length,
      itemBuilder: (context, index) {
        final item = _data[index];
        final isSelected = _selectedItem == item;
        
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          elevation: isSelected ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected 
                ? BorderSide(color: Colors.blue[600]!, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[600] : Colors.grey[600],
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
                color: isSelected ? Colors.blue[800] : Colors.grey[800],
              ),
            ),
            subtitle: Text(
              'Index: ${index + 1}',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue[600] : Colors.grey[600],
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[600],
                    size: 24,
                  )
                : Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.grey[400],
                    size: 24,
                  ),
            onTap: () => _selectItem(item),
            onLongPress: () => _showItemOptions(item, index),
          ),
        );
      },
    );
  }

  void _selectItem(String item) {
    setState(() {
      _selectedItem = item;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $item'),
        backgroundColor: Colors.blue[600],
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedItem = null;
    });
  }

  void _addNewItem() {
    setState(() {
      _data.add('Item $_itemCounter');
      _itemCounter++;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added: Item ${_itemCounter - 1}'),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteSelectedItem() {
    if (_selectedItem != null) {
      setState(() {
        _data.remove(_selectedItem);
        _selectedItem = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted: $_selectedItem'),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _addSelectedToData() {
    if (_selectedItem != null) {
      setState(() {
        _data.add(_selectedItem!);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to list: $_selectedItem'),
          backgroundColor: Colors.blue[600],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetList() {
    setState(() {
      _data = [
        'Item 1',
        'Item 2',
        'Item 3',
        'Item 4',
      ];
      _itemCounter = 5;
      _selectedItem = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('List reset to original state'),
        backgroundColor: Colors.orange[600],
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showItemOptions(String item, int index) {
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
                  'Item Options',
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
              _buildDetailRow('Index', '${index + 1}'),
              _buildDetailRow('Total Items', '${_data.length}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _selectItem(item);
              },
              child: Text(
                'Select',
                style: TextStyle(color: Colors.blue[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _data.removeAt(index);
                  if (_selectedItem == item) {
                    _selectedItem = null;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted: $item'),
                    backgroundColor: Colors.red[600],
                  ),
                );
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
}

