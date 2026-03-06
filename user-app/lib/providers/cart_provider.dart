// filepath: lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopflow/models/cart_item_model.dart';
import 'package:shopflow/providers/auth_provider.dart';
import 'package:shopflow/services/cart_service.dart';

/// 🔹 Cart service singleton
final cartServiceProvider = Provider<CartService>((ref) {
  return CartService();
});

/// 🔹 Stream of cart items for current user
final cartItemsProvider = StreamProvider<List<CartItemModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }
  return ref.watch(cartServiceProvider).watchCartItems(userId);
});

/// 🔹 Total number of items in cart (sum of quantities)
final cartItemCountProvider = Provider<int>((ref) {
  final itemsAsync = ref.watch(cartItemsProvider);
  return itemsAsync.when(
    data: (items) => items.fold(0, (sum, item) => sum + item.quantity),
    loading: () => 0,
    error: (_, _) => 0,
  );
});

/// 🔹 Subtotal (sum of price * quantity)
final cartTotalProvider = Provider<double>((ref) {
  final itemsAsync = ref.watch(cartItemsProvider);
  return itemsAsync.when(
    data: (items) =>
        items.fold(0.0, (sum, item) => sum + item.price * item.quantity),
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});

/// 🔹 Shipping cost calculation (free over 100, otherwise constant)
final shippingCostProvider = Provider<double>((ref) {
  final total = ref.watch(cartTotalProvider);
  if (total == 0) return 0.0;
  return total >= 100.0 ? 0.0 : 5.0;
});

/// 🔹 Grand total (subtotal + shipping)
final grandTotalProvider = Provider<double>((ref) {
  return ref.watch(cartTotalProvider) + ref.watch(shippingCostProvider);
});

/// 🔹 Cart actions notifier
class CartNotifier extends StateNotifier<AsyncValue<void>> {
  final CartService _cartService;
  final Ref _ref;

  CartNotifier(this._cartService, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> addToCart({
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
    required int quantity,
    BuildContext? context,
  }) async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;
    state = const AsyncValue.loading();
    try {
      await _cartService.addToCart(
        userId: userId,
        productId: productId,
        productName: productName,
        price: price,
        imageUrl: imageUrl,
        quantity: quantity,
        context: context,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
    BuildContext? context,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _cartService.updateQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
        context: context,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeFromCart({
    required String cartItemId,
    BuildContext? context,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _cartService.removeFromCart(
        cartItemId: cartItemId,
        context: context,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearCart({BuildContext? context}) async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;
    state = const AsyncValue.loading();
    try {
      await _cartService.clearCart(userId: userId, context: context);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<void>>((ref) {
      return CartNotifier(ref.watch(cartServiceProvider), ref);
    });
