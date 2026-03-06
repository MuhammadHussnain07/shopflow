import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final _service = ProductService();
  List<ProductModel> _products = [];
  bool _loading = false;
  String _selectedCategory = 'All';

  List<ProductModel> get products {
    if (_selectedCategory == 'All') return _products;
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  bool get loading => _loading;
  String get selectedCategory => _selectedCategory;

  void listenToProducts() {
    _loading = true;
    notifyListeners();
    _service.getProducts().listen((list) {
      _products = list;
      _loading = false;
      notifyListeners();
    });
  }

  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  Future<void> addProduct(ProductModel p) async {
    await _service.addProduct(p);
  }

  Future<void> updateProduct(ProductModel p) async {
    await _service.updateProduct(p);
  }

  Future<void> deleteProduct(String id) async {
    await _service.deleteProduct(id);
  }
}
