// filepath: lib/services/cart_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopflow/models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _cartCollection = FirebaseFirestore.instance
      .collection('cart');

  Stream<List<CartItemModel>> watchCartItems(String userId) {
    // Avoid server-side ordering (which can require composite indexes)
    // and instead sort client-side by `createdAt` to keep this query index-free.
    return _cartCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .handleError((e) {
          // Log errors (e.g. missing index) but don't crash the stream.
          // ignore: avoid_print
          print('Firestore watchCartItems error: $e');
        })
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => CartItemModel.fromFirestore(doc))
              .toList();
          items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return items;
        });
  }

  Future<void> addToCart({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
    BuildContext? context,
    int quantity = 1,
  }) async {
    try {
      final existing = await _cartCollection
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        final currentQty =
            (doc.data() as Map<String, dynamic>)['quantity'] as int;
        await doc.reference.update({'quantity': currentQty + quantity});

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cart updated successfully!')),
          );
        }
      } else {
        await _cartCollection.add({
          'userId': userId,
          'productId': productId,
          'productName': productName,
          'price': price,
          'imageUrl': imageUrl,
          'quantity': quantity,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Added to cart!')));
        }
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add to cart: $e')));
      }
    }
  }

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
    BuildContext? context,
  }) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(cartItemId: cartItemId, context: context);
        return;
      }
      await _cartCollection.doc(cartItemId).update({'quantity': quantity});
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quantity: $e')),
        );
      }
    }
  }

  Future<void> removeFromCart({
    required String cartItemId,
    BuildContext? context,
  }) async {
    try {
      await _cartCollection.doc(cartItemId).delete();
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart.')),
        );
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove item: $e')));
      }
    }
  }

  Future<void> clearCart({
    required String userId,
    BuildContext? context,
  }) async {
    try {
      final snapshot = await _cartCollection
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to clear cart: $e')));
      }
    }
  }

  Future<int> getCartItemCount(String userId) async {
    try {
      final snapshot = await _cartCollection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.fold<int>(
        0,
        (total, doc) =>
            total + ((doc.data() as Map<String, dynamic>)['quantity'] as int),
      );
    } catch (_) {
      return 0;
    }
  }

  Future<bool> isProductInCart({
    required String userId,
    required String productId,
  }) async {
    try {
      final snapshot = await _cartCollection
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
