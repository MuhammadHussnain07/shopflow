// filepath: lib/services/order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopflow/models/cart_item_model.dart';
import 'package:shopflow/models/order_model.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _ordersCollection = FirebaseFirestore.instance
      .collection('orders');
  final CollectionReference _cartCollection = FirebaseFirestore.instance
      .collection('cart');

  Stream<List<OrderModel>> watchUserOrders(String userId) {
    // Avoid server-side ordering to prevent composite-index requirements;
    // sort client-side by createdAt (newest first).
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .handleError((e) {
          // ignore: avoid_print
          print('Firestore watchUserOrders error: $e');
        })
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  Future<OrderModel?> fetchOrderById({
    required String orderId,
    BuildContext? context,
  }) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (!doc.exists) return null;
      return OrderModel.fromFirestore(doc);
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load order: $e')));
      }
      return null;
    }
  }

  Future<String?> placeOrder({
    required String userId,
    required List<CartItemModel> cartItems,
    required double total,
    required String shippingAddress,
    required String paymentMethod,
    BuildContext? context,
  }) async {
    try {
      final orderId = const Uuid().v4();

      final orderItems = cartItems
          .map(
            (item) => OrderItem(
              productId: item.productId,
              productName: item.productName,
              imageUrl: item.imageUrl,
              price: item.price,
              quantity: item.quantity,
            ),
          )
          .toList();

      final order = OrderModel(
        id: orderId,
        userId: userId,
        items: orderItems,
        total: total,
        status: OrderStatus.confirmed,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );

      final batch = _firestore.batch();

      final orderRef = _ordersCollection.doc(orderId);
      // Ensure nested OrderItem objects are converted to plain maps before sending
      final orderMap = order.toFirestore();
      orderMap['items'] = orderItems.map((i) => i.toJson()).toList();
      // Use server timestamp for createdAt to keep consistency
      orderMap['createdAt'] = FieldValue.serverTimestamp();
      batch.set(orderRef, orderMap);

      final cartSnapshot = await _cartCollection
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      return orderId;
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
      }
      return null;
    }
  }

  Future<bool> cancelOrder({
    required String orderId,
    BuildContext? context,
  }) async {
    try {
      await _ordersCollection.doc(orderId).update({'status': 'cancelled'});

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully.')),
        );
      }
      return true;
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to cancel order: $e')));
      }
      return false;
    }
  }

  Future<List<OrderModel>> fetchAllUserOrders({
    required String userId,
    BuildContext? context,
  }) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .get();

      final items = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
      }
      return [];
    }
  }
}
