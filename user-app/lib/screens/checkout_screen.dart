// filepath: lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shopflow/core/router/app_router.dart';

import 'package:shopflow/core/theme/app_theme.dart';
import 'package:shopflow/providers/cart_provider.dart';
import 'package:shopflow/providers/order_provider.dart';

class CheckoutScreen extends HookConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final selectedPayment = ref.watch(selectedPaymentMethodProvider);
    final cartItems = ref.watch(cartItemsProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final shippingCost = ref.watch(shippingCostProvider);
    final grandTotal = ref.watch(grandTotalProvider);
    final orderState = ref.watch(orderNotifierProvider);
    final isLoading = orderState.isLoading;

    final paymentMethods = [
      'Cash on Delivery',
      'Credit Card',
      'Debit Card',
      'Bank Transfer',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Iconsax.arrow_left),
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipping address section
              _SectionTitle(title: 'Shipping Address'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: addressController,
                  maxLines: 3,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your full shipping address...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(
                        Iconsax.location,
                        color: AppColors.textGrey,
                        size: 20,
                      ),
                    ),
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Shipping address is required';
                    }
                    if (value.trim().length < 10) {
                      return 'Please enter a complete address';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Payment method section
              _SectionTitle(title: 'Payment Method'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: paymentMethods.map((method) {
                    final isSelected = selectedPayment == method;
                    return GestureDetector(
                      onTap: () =>
                          ref
                                  .read(selectedPaymentMethodProvider.notifier)
                                  .state = method,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _paymentIcon(method),
                              size: 22,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textGrey,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              method,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textDark,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.divider,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Order summary section
              _SectionTitle(title: 'Order Summary'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    cartItems.whenOrNull(
                          data: (items) => Column(
                            children: items
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${item.productName} x${item.quantity}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: AppColors.textGrey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                          Text(
                                            item.subtotal.toStringAsFixed(2),
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ) ??
                        const SizedBox.shrink(),
                    const Divider(height: 24),
                    _CheckoutRow(
                      label: 'Subtotal',
                      value: cartTotal.toStringAsFixed(2),
                    ),
                    const SizedBox(height: 8),
                    _CheckoutRow(
                      label: 'Shipping',
                      value: shippingCost == 0
                          ? 'FREE'
                          : shippingCost.toStringAsFixed(2),
                      valueColor: shippingCost == 0
                          ? AppColors.success
                          : AppColors.textDark,
                    ),
                    const Divider(height: 24),
                    _CheckoutRow(
                      label: 'Grand Total',
                      value: grandTotal.toStringAsFixed(2),
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              GradientButton(
                text: 'Place Order',
                icon: Iconsax.tick_circle,
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () => _placeOrder(
                        context,
                        ref,
                        formKey,
                        addressController,
                        selectedPayment,
                        grandTotal,
                      ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  IconData _paymentIcon(String method) {
    switch (method) {
      case 'Cash on Delivery':
        return Iconsax.money;
      case 'Credit Card':
        return Iconsax.card;
      case 'Debit Card':
        return Iconsax.card_add;
      case 'Bank Transfer':
        return Iconsax.bank;
      default:
        return Iconsax.wallet;
    }
  }

  Future<void> _placeOrder(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    TextEditingController addressController,
    String selectedPayment,
    double grandTotal,
  ) async {
    if (!formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final cartItems = ref.read(cartItemsProvider).value ?? [];
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    final orderId = await ref
        .read(orderNotifierProvider.notifier)
        .placeOrder(
          cartItems: cartItems,
          total: grandTotal,
          shippingAddress: addressController.text.trim(),
          paymentMethod: selectedPayment,
          context: context,
        );

    if (orderId != null && context.mounted) {
      ref.read(lastPlacedOrderIdProvider.notifier).state = orderId;
      context.go(AppRoutes.orderSuccess);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }
}

class _CheckoutRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _CheckoutRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.textGrey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 17 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
