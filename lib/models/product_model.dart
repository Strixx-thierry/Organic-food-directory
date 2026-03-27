import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String price;
  final String category;
  final String image;
  final String? phone;
  final String? fresh;
  final String? organic;
  final String? farm;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.image,
    this.phone,
    this.fresh,
    this.organic,
    this.farm,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['sub'] ?? '',
      price: map['price'] ?? '',
      category: map['category'] ?? '',
      image: map['image'] ?? 'assets/placeholder.png',
      phone: map['phone'],
      fresh: map['fresh'],
      organic: map['organic'],
      farm: map['farm'],
    );
  }

  @override
  List<Object?> get props => [id, name, description, price, category, image, phone, fresh, organic, farm];
}