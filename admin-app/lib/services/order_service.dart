import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;
  final _col = 'orders';

  Stream<List<OrderModel>> getOrders() {
    return _db
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection(_col).doc(orderId).update({'status': status});
  }

  Future<int> getOrderCount() async {
    final snap = await _db.collection(_col).count().get();
    return snap.count ?? 0;
  }

  Future<int> getPendingCount() async {
    final snap = await _db
        .collection(_col)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<double> getTotalRevenue() async {
    final snap = await _db.collection(_col).get();
    double total = 0;
    for (final doc in snap.docs) {
      total += (doc.data()['total'] ?? 0).toDouble();
    }
    return total;
  }
}
