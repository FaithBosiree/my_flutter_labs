import 'package:floor/floor.dart';

import 'shopping_item.dart';

@dao
abstract class ShoppingItemDao {
  @Query(
    'SELECT * FROM ShoppingItem ORDER BY id ASC',
  )
  Future<List<ShoppingItem>> getAllItems();

  @insert
  Future<int> insertItem(ShoppingItem item);

  @delete
  Future<void> deleteItem(ShoppingItem item);
}