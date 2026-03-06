// filepath: lib/providers/product_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopflow/models/product_model.dart';
import 'package:shopflow/services/product_service.dart';

/// 🔹 Product service singleton
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

/// 🔹 All products stream
final allProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.watch(productServiceProvider).watchAllProducts();
});

/// 🔹 Products filtered by selected category
final productsByCategoryProvider =
    StreamProvider.family<List<ProductModel>, String>((ref, category) {
      if (category == 'All') {
        return ref.watch(productServiceProvider).watchAllProducts();
      }
      return ref
          .watch(productServiceProvider)
          .watchProductsByCategory(category);
    });

/// 🔹 New arrivals
final newArrivalsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.watch(productServiceProvider).watchNewArrivals(limit: 4);
});

/// 🔹 Single product by ID
final productByIdProvider = FutureProvider.family<ProductModel?, String>((
  ref,
  productId,
) async {
  return ref
      .watch(productServiceProvider)
      .fetchProductById(
        productId: productId,
        context: null, // ✅ FIXED
      );
});

/// 🔹 Selected category
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

/// 🔹 All categories
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final categories = await ref
      .watch(productServiceProvider)
      .fetchCategories(context: null); // ✅ FIXED

  return ['All', ...categories];
});

/// 🔹 Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 🔹 Search results
final searchResultsProvider = FutureProvider.family<List<ProductModel>, String>(
  (ref, query) async {
    if (query.trim().isEmpty) return [];

    return ref
        .watch(productServiceProvider)
        .searchProducts(
          query: query,
          context: null, // ✅ FIXED
        );
  },
);

/// 🔹 Featured products
final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) {
  return ref
      .watch(productServiceProvider)
      .fetchFeaturedProducts(
        context: null, // ✅ FIXED
        limit: 6,
      );
});

/// 🔹 Wishlist (local state)
final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<String>>((
  ref,
) {
  return WishlistNotifier();
});

class WishlistNotifier extends StateNotifier<Set<String>> {
  WishlistNotifier() : super({});

  void toggle(String productId) {
    // Make an explicit copy to ensure Riverpod detects the state change
    final newSet = Set<String>.from(state);
    if (newSet.contains(productId)) {
      newSet.remove(productId);
      // ignore: avoid_print
      print('Wishlist: removed $productId');
    } else {
      newSet.add(productId);
      // ignore: avoid_print
      print('Wishlist: added $productId');
    }
    state = newSet;
  }

  bool isWishlisted(String productId) => state.contains(productId);
}
