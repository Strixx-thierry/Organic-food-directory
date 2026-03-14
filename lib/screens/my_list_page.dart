import 'package:flutter/material.dart';

class MyListPage extends StatefulWidget {
  const MyListPage({super.key});

  @override
  State<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  // Placeholder lists — will be replaced with Firestore data
  final List<Map<String, dynamic>> _lists = [
    {
      'title': 'Weekly Groceries',
      'itemCount': 8,
      'color': Colors.green,
      'icon': Icons.shopping_basket_outlined,
      'items': ['Spinach', 'Tomatoes', 'Apples', 'Eggs', 'Milk', 'Carrots', 'Onions', 'Garlic'],
    },
    {
      'title': 'Smoothie Ingredients',
      'itemCount': 4,
      'color': Colors.orange,
      'icon': Icons.blender_outlined,
      'items': ['Bananas', 'Strawberries', 'Greek Yogurt', 'Honey'],
    },
    {
      'title': 'Salad Fixings',
      'itemCount': 5,
      'color': Colors.teal,
      'icon': Icons.eco_outlined,
      'items': ['Lettuce', 'Cucumber', 'Cherry Tomatoes', 'Avocado', 'Lemon'],
    },
  ];

  void _showCreateListDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Create New List',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'List name...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _lists.add({
                    'title': controller.text.trim(),
                    'itemCount': 0,
                    'color': Colors.purple,
                    'icon': Icons.list_alt_outlined,
                    'items': <String>[],
                  });
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteList(int index) {
    final title = _lists[index]['title'];
    setState(() => _lists.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$title" deleted'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openList(Map<String, dynamic> list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ListDetailPage(list: list),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Lists',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showCreateListDialog,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Lists
              Expanded(
                child: _lists.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        itemCount: _lists.length,
                        itemBuilder: (ctx, i) => _listCard(_lists[i], i),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listCard(Map<String, dynamic> list, int index) {
    final color = list['color'] as MaterialColor;
    return GestureDetector(
      onTap: () => _openList(list),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(list['icon'] as IconData,
                  color: color[700], size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${list['itemCount']} items',
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[300]),
              onPressed: () => _deleteList(index),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.list_alt_outlined,
                size: 60, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Lists Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first shopping list!',
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateListDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Create List',
                style: TextStyle(color: Colors.white, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
      ),
    );
  }
}

// Detail screen when a list is tapped
class _ListDetailPage extends StatefulWidget {
  final Map<String, dynamic> list;
  const _ListDetailPage({required this.list});

  @override
  State<_ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<_ListDetailPage> {
  late List<String> _items;
  late List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _items = List<String>.from(widget.list['items'] as List);
    _checked = List<bool>.filled(_items.length, false);
  }

  void _addItem() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Item',
            style: TextStyle(
                color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Item name...',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _items.add(controller.text.trim());
                  _checked.add(false);
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkedCount = _checked.where((c) => c).length;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.list['title'],
          style: const TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF2E7D32), size: 28),
            onPressed: _addItem,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$checkedCount of ${_items.length} items done',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _items.isEmpty
                              ? 0
                              : checkedCount / _items.length,
                          backgroundColor: Colors.green[100],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF2E7D32)),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Items list
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (ctx, i) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CheckboxListTile(
                    value: _checked[i],
                    onChanged: (v) =>
                        setState(() => _checked[i] = v ?? false),
                    title: Text(
                      _items[i],
                      style: TextStyle(
                        fontSize: 15,
                        color: _checked[i]
                            ? Colors.grey[400]
                            : const Color(0xFF1B5E20),
                        decoration: _checked[i]
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    activeColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    secondary: IconButton(
                      icon: Icon(Icons.close,
                          color: Colors.red[300], size: 18),
                      onPressed: () =>
                          setState(() {
                            _items.removeAt(i);
                            _checked.removeAt(i);
                          }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}