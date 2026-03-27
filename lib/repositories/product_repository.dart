import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snap = await _firestore.collection('products').get();
      return snap.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('Error fetching from Firestore: $e');
      return [];
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final all = await getAllProducts();
    final q = query.toLowerCase();
    return all.where((p) => p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q)).toList();
  }

  Future<ProductModel> getProduct(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() ?? {}, id);
      }
    } catch (e) {
      debugPrint('Error fetching product: $e');
      throw Exception('Product not found: $id');
    }
    throw Exception('Product not found: $id');
  }

  /// Real-time stream of all products from Firestore.
  Stream<List<ProductModel>> productsStream() {
    return _firestore.collection('products').snapshots().map(
          (snap) => snap.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Upload image bytes to Cloudinary and return the secure download URL.
  Future<String> uploadProductImage(Uint8List bytes) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'product.jpg'));
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed: ${response.statusCode}');
    }
    final body = jsonDecode(await response.stream.bytesToString());
    return body['secure_url'] as String;
  }

  /// Write a new product document to Firestore.
  Future<void> addProduct(Map<String, dynamic> data) async {
    await _firestore.collection('products').add(data);
  }
}