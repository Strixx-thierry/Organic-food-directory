import 'package:flutter_test/flutter_test.dart';
import 'package:organic_food_directory/models/product_model.dart';

void main() {
  group('ProductModel', () {
    test('fromMap creates a product with the correct fields', () {
      final map = {
        'name': 'Organic Tomatoes',
        'sub': 'Fresh from the farm',
        'price': '\$3.99',
        'category': 'Vegetables',
        'image': 'https://example.com/tomato.jpg',
      };

      final product = ProductModel.fromMap(map, 'product_001');

      expect(product.id, 'product_001');
      expect(product.name, 'Organic Tomatoes');
      expect(product.price, '\$3.99');
      expect(product.category, 'Vegetables');
    });

    test('fromMap uses placeholder image when image field is missing', () {
      final map = {
        'name': 'Organic Apples',
        'sub': 'Red and crispy',
        'price': '\$4.99',
        'category': 'Fruits',
      };

      final product = ProductModel.fromMap(map, 'product_002');

      expect(product.image, 'assets/placeholder.png');
    });

    test('two products with the same data are equal', () {
      final map = {
        'name': 'Organic Carrots',
        'sub': 'Baby carrots',
        'price': '\$2.49',
        'category': 'Vegetables',
        'image': 'assets/placeholder.png',
      };

      final p1 = ProductModel.fromMap(map, 'product_003');
      final p2 = ProductModel.fromMap(map, 'product_003');

      expect(p1, equals(p2));
    });
  });
}
