// filepath: lib/services/product_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopflow/models/product_model.dart';

class ProductService {
  final CollectionReference _productsCollection = FirebaseFirestore.instance
      .collection('products');

  Stream<List<ProductModel>> watchAllProducts() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<ProductModel>> watchProductsByCategory(String category) {
    // Avoid server-side ordering combined with filters (which may require
    // a composite index). Query by category then sort client-side by createdAt.
    return _productsCollection
        .where('category', isEqualTo: category)
        .snapshots()
        .handleError((e) {
          // Log and swallow so UI can show empty/error state without crashing.
          // ignore: avoid_print
          print('Firestore watchProductsByCategory error: $e');
        })
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  Future<ProductModel?> fetchProductById({
    required String productId,
    BuildContext? context,
  }) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (!doc.exists) return null;
      return ProductModel.fromFirestore(doc);
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load product: $e')));
      }
      return null;
    }
  }

  Future<List<ProductModel>> searchProducts({
    required String query,
    BuildContext? context,
  }) async {
    try {
      final queryLower = query.toLowerCase().trim();

      final snapshot = await _productsCollection
          .orderBy('createdAt', descending: true)
          .get();

      final all = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      return all.where((product) {
        return product.name.toLowerCase().contains(queryLower) ||
            product.category.toLowerCase().contains(queryLower) ||
            product.description.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
      return [];
    }
  }

  Future<List<ProductModel>> fetchFeaturedProducts({
    BuildContext? context,
    int limit = 6,
  }) async {
    try {
      final snapshot = await _productsCollection
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load featured products: $e')),
        );
      }
      return [];
    }
  }

  Future<List<String>> fetchCategories({BuildContext? context}) async {
    try {
      final snapshot = await _productsCollection.get();
      final categories = snapshot.docs
          .map(
            (doc) => (doc.data() as Map<String, dynamic>)['category'] as String,
          )
          .toSet()
          .toList();
      categories.sort();
      return categories;
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
      return [];
    }
  }

  Stream<List<ProductModel>> watchNewArrivals({int limit = 4}) {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList(),
        );
  }
}
