import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
    productId: map['productId'] ?? '',
    productName: map['productName'] ?? '',
    price: (map['price'] ?? 0).toDouble(),
    quantity: (map['quantity'] ?? 1).toInt(),
    imageUrl: map['imageUrl'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'price': price,
    'quantity': quantity,
    'imageUrl': imageUrl,
  };
}

class OrderModel {
  final String id;
  final String userId;
  final String customerEmail;
  final List<OrderItem> items;
  final double total;
  final String status;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerEmail,
    required this.items,
    required this.total,
    required this.status,
    this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      customerEmail: map['customerEmail'] ?? 'N/A',
      items: rawItems
          .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      total: (map['total'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
