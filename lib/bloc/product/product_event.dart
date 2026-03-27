import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object> get props => [];
}

class LoadProductsEvent extends ProductEvent {}

class SearchProductsEvent extends ProductEvent {
  final String query;
  const SearchProductsEvent(this.query);
  @override
  List<Object> get props => [query];
}

class LoadProductDetailEvent extends ProductEvent {
  final String id;
  const LoadProductDetailEvent(this.id);
  @override
  List<Object> get props => [id];
}

class AddProductEvent extends ProductEvent {
  final String name;
  final String description;
  final String price;
  final String category;
  final Uint8List imageBytes;
  final String phone;
  final String fresh;
  final String organic;
  final String farm;
  final String userId;

  const AddProductEvent({
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageBytes,
    required this.phone,
    required this.fresh,
    required this.organic,
    required this.farm,
    required this.userId,
  });

  @override
  List<Object> get props =>
      [name, description, price, category, imageBytes, phone, fresh, organic, farm, userId];
}

class EditProductEvent extends ProductEvent {
  final String productId;
  final String name;
  final String description;
  final String price;
  final String category;
  final Uint8List? newImageBytes;
  final String currentImageUrl;
  final String phone;
  final String fresh;
  final String organic;
  final String farm;

  const EditProductEvent({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.newImageBytes,
    required this.currentImageUrl,
    required this.phone,
    required this.fresh,
    required this.organic,
    required this.farm,
  });

  @override
  List<Object> get props =>
      [productId, name, description, price, category, currentImageUrl, phone, fresh, organic, farm];
}

class DeleteProductEvent extends ProductEvent {
  final String productId;
  const DeleteProductEvent(this.productId);
  @override
  List<Object> get props => [productId];
}
