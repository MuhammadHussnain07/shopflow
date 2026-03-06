import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;
  final _col = 'products';

  Stream<List<ProductModel>> getProducts() {
    return _db
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ProductModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  Future<void> addProduct(ProductModel product) async {
    await _db.collection(_col).add({
      ...product.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db.collection(_col).doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  Future<int> getProductCount() async {
    final snap = await _db.collection(_col).count().get();
    return snap.count ?? 0;
  }
}
