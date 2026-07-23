import 'package:flutter/material.dart';

import 'database/app_database.dart';
import 'database/shopping_item.dart';
import 'database/shopping_item_dao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppDatabase database = await $FloorAppDatabase
      .databaseBuilder('shopping_database.db')
      .build();

  runApp(
    MyApp(database: database),
  );
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp({
    super.key,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping List',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: ShoppingListPage(database: database),
    );
  }
}

class ShoppingListPage extends StatefulWidget {
  final AppDatabase database;

  const ShoppingListPage({
    super.key,
    required this.database,
  });

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final List<ShoppingItem> shoppingList = [];

  late final ShoppingItemDao shoppingItemDao;

  @override
  void initState() {
    super.initState();

    shoppingItemDao = widget.database.shoppingItemDao;
    loadShoppingItems();
  }

  Future<void> loadShoppingItems() async {
    final List<ShoppingItem> savedItems =
    await shoppingItemDao.getAllItems();

    if (!mounted) {
      return;
    }

    setState(() {
      shoppingList.clear();
      shoppingList.addAll(savedItems);
    });
  }

  Future<void> addShoppingItem() async {
    final String itemName = itemController.text.trim();
    final String quantity = quantityController.text.trim();

    if (itemName.isEmpty || quantity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an item and quantity.'),
        ),
      );

      return;
    }

    final ShoppingItem newItem = ShoppingItem(
      name: itemName,
      quantity: quantity,
    );

    final int generatedId =
    await shoppingItemDao.insertItem(newItem);

    final ShoppingItem savedItem = ShoppingItem(
      id: generatedId,
      name: itemName,
      quantity: quantity,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      shoppingList.add(savedItem);
    });

    itemController.clear();
    quantityController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName added to the database.'),
      ),
    );
  }

  Future<void> deleteShoppingItem(ShoppingItem item) async {
    await shoppingItemDao.deleteItem(item);

    if (!mounted) {
      return;
    }

    setState(() {
      shoppingList.removeWhere(
            (ShoppingItem shoppingItem) =>
        shoppingItem.id == item.id,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} deleted.'),
      ),
    );
  }

  Future<void> showDeleteDialog(ShoppingItem item) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete item'),
          content: Text(
            'Do you want to delete ${item.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await deleteShoppingItem(item);
    }
  }

  @override
  void dispose() {
    itemController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        backgroundColor:
        Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: itemController,
              decoration: const InputDecoration(
                labelText: 'Shopping item',
                hintText: 'Example: Milk',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Example: 2',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addShoppingItem,
                child: const Text('Click Here'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: shoppingList.isEmpty
                  ? const Center(
                child: Text(
                  'No shopping items have been added.',
                ),
              )
                  : ListView.builder(
                itemCount: shoppingList.length,
                itemBuilder:
                    (BuildContext context, int index) {
                  final ShoppingItem item =
                  shoppingList[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.shopping_cart,
                      ),
                      title: Text(item.name),
                      subtitle: Text(
                        'Quantity: ${item.quantity}',
                      ),
                      trailing: const Icon(
                        Icons.touch_app,
                      ),
                      onLongPress: () {
                        showDeleteDialog(item);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}