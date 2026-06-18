import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping List App',
      theme: ThemeData(
        // app ui
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD7C4FA),
          foregroundColor: Colors.black,
        ),
      ),
      home: const ShoppingPage(),
    );
  }
}

// Stores the item name and its quantity together
class ShoppingItem {
  String name;
  String quantity;

  ShoppingItem({required this.name, required this.quantity});
}

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  // list for shopping items
  final List<ShoppingItem> _shoppingList = [];

  // text input controllers
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // UI-widget isolation
  Widget ListPage() {
    return Column(
      children: [
        // list arrangement
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Row(
            children: [
              // item name input field
              Expanded(
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.only(right: 4),
                  child: TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      hintText: 'Type the item here',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
              // Quantity Input Field
              Expanded(
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.only(right: 8),
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      hintText: 'Type the quantity here',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
              // action button, Click here.
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _addItem,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6F2FF),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Click here',
                    style: TextStyle(color: Color(0xFF7A52B3)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // interactive item list
        Expanded(
          child: _shoppingList.isEmpty
              ? const Center(
            // Required backup text display when item list tracking is zero
            child: Text(
              "There are no items in the list",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: _shoppingList.length,
            itemBuilder: (context, index) {
              final currentItem = _shoppingList[index];
              final rowNumber = index + 1;

              // 3: gesture detector tracking targeting individual rows
              return GestureDetector(
                onLongPress: () => _showDeleteDialog(index, currentItem.name),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Format: "X: ItemName quantity: Y" as requested and visually indicated
                      Text(
                        "$rowNumber: ${currentItem.name}  quantity: ${currentItem.quantity}",
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Adds typed text elements to data arrays and mutates state
  void _addItem() {
    final String nameInput = _itemController.text.trim();
    final String qtyInput = _quantityController.text.trim();

    if (nameInput.isNotEmpty && qtyInput.isNotEmpty) {
      setState(() {
        // //1: Typing an item in the TextField and clicking the "add" button makes the item appear in the list.
        _shoppingList.add(ShoppingItem(name: nameInput, quantity: qtyInput));

        // //2: After inserting an item, the TextField is cleared so that the previous string is gone.
        _itemController.clear();
        _quantityController.clear();
      });
    }
  }

  // Triggers an AlertDialog popup confirming item row processing deletion routines
  void _showDeleteDialog(int index, String itemName) {
    // //3: If the user long-presses an item in the list, an AlertDialog appears asking if they want to delete the item.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: Text("Are you sure you want to delete '$itemName'?"),
          actions: [
            TextButton(
              onPressed: () {
                // //task 5: Selecting "No" from the AlertDialog does not remove the item from the list.
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                // //task 4: Selecting "Yes" from the AlertDialog removes the item from the list.
                setState(() {
                  _shoppingList.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
        centerTitle: true,
        elevation: 0,
      ),
      // Running clean decoupled function tracking UI components
      body: ListPage(),
    );
  }
}