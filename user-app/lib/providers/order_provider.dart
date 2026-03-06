// filepath: lib/providers/order_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopflow/models/cart_item_model.dart';
import 'package:shopflow/models/order_model.dart';
import 'package:shopflow/providers/auth_provider.dart';
import 'package:shopflow/services/order_service.dart';

// Order service singleton
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// Real-time orders stream for the current user
final userOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  return ref.watch(orderServiceProvider).watchUserOrders(userId);
});

// Single order by ID
final orderByIdProvider = FutureProvider.family<OrderModel?, String>((
  ref,
  orderId,
) async {
  return ref
      .watch(orderServiceProvider)
      .fetchOrderById(orderId: orderId, context: null);
});

// Active orders (pending, confirmed, processing, shipped)
final activeOrdersProvider = Provider<List<OrderModel>>((ref) {
  final ordersAsync = ref.watch(userOrdersProvider);
  return ordersAsync.whenOrNull(
        data: (orders) => orders.where((o) => o.status.isActive).toList(),
      ) ??
      [];
});

// Completed / delivered orders
final completedOrdersProvider = Provider<List<OrderModel>>((ref) {
  final ordersAsync = ref.watch(userOrdersProvider);
  return ordersAsync.whenOrNull(
        data: (orders) =>
            orders.where((o) => o.status == OrderStatus.delivered).toList(),
      ) ??
      [];
});

// Order count
final orderCountProvider = Provider<int>((ref) {
  final ordersAsync = ref.watch(userOrdersProvider);
  return ordersAsync.whenOrNull(data: (orders) => orders.length) ?? 0;
});

// Selected payment method state
final selectedPaymentMethodProvider = StateProvider<String>(
  (ref) => 'Cash on Delivery',
);

// Shipping address state
final shippingAddressProvider = StateProvider<String>((ref) => '');

// Order placement notifier
class OrderNotifier extends StateNotifier<AsyncValue<void>> {
  final OrderService _orderService;
  final Ref _ref;

  OrderNotifier(this._orderService, this._ref)
    : super(const AsyncValue.data(null));

  Future<String?> placeOrder({
    required List<CartItemModel> cartItems,
    required double total,
    required String shippingAddress,
    required String paymentMethod,
    required dynamic context,
  }) async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return null;

    state = const AsyncValue.loading();
    try {
      final orderId = await _orderService.placeOrder(
        userId: userId,
        cartItems: cartItems,
        total: total,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        context: context,
      );
      state = const AsyncValue.data(null);
      return orderId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> cancelOrder({
    required String orderId,
    required dynamic context,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await _orderService.cancelOrder(
        orderId: orderId,
        context: context,
      );
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<void>>((ref) {
      return OrderNotifier(ref.watch(orderServiceProvider), ref);
    });

// Last placed order ID — used to navigate to order success screen
final lastPlacedOrderIdProvider = StateProvider<String?>((ref) => null);
