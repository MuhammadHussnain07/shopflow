import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final _service = OrderService();
  List<OrderModel> _orders = [];
  bool _loading = false;
  String _filter = 'All';

  List<OrderModel> get orders {
    if (_filter == 'All') return _orders;
    return _orders
        .where((o) => o.status.toLowerCase() == _filter.toLowerCase())
        .toList();
  }

  bool get loading => _loading;
  String get filter => _filter;

  void listenToOrders() {
    _loading = true;
    notifyListeners();
    _service.getOrders().listen((list) {
      _orders = list;
      _loading = false;
      notifyListeners();
    });
  }

  void setFilter(String f) {
    _filter = f;
    notifyListeners();
  }

  Future<void> updateStatus(String orderId, String status) async {
    await _service.updateOrderStatus(orderId, status);
  }

  int get totalOrders => _orders.length;
  int get pendingOrders => _orders.where((o) => o.status == 'pending').length;
  double get totalRevenue => _orders.fold(0, (sum, o) => sum + o.total);
}
