import 'package:flutter_test/flutter_test.dart';
import 'package:organic_food_directory/models/list_model.dart';

void main() {
  group('ListModel', () {
    final now = DateTime(2024, 6, 15);

    test('fromMap uses default color and icon when they are missing', () {
      final map = {
        'id': 'list_001',
        'title': 'My Shopping List',
        'items': <String>[],
        'createdAt': now,
        'updatedAt': now,
      };

      final list = ListModel.fromMap(map);

      expect(list.color, 'green');
      expect(list.icon, 'shopping_basket_outlined');
    });

    test('copyWith updates title while keeping the rest unchanged', () {
      final list = ListModel(
        id: 'list_001',
        title: 'Weekly Groceries',
        items: const ['Apples', 'Milk'],
        createdAt: now,
        updatedAt: now,
      );

      final updated = list.copyWith(title: 'Weekend Shop');

      expect(updated.title, 'Weekend Shop');
      expect(updated.id, 'list_001');
      expect(updated.items, ['Apples', 'Milk']);
    });
  });
}
