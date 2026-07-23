import 'package:floor/floor.dart';

@entity
class ShoppingItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;
  final String quantity;

  const ShoppingItem({
    this.id,
    required this.name,
    required this.quantity,
  });
}