import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopflow/core/theme/app_theme.dart';
import 'package:shopflow/providers/product_provider.dart';
import 'package:shopflow/widgets/product_card.dart';
import 'package:go_router/go_router.dart';
import 'package:shopflow/core/router/app_router.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Wishlist'),
      ),
      backgroundColor: AppColors.background,
      body: productsAsync.when(
        data: (products) {
          final items = products.where((p) => wishlist.contains(p.id)).toList();

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.favorite_border,
                    size: 56,
                    color: AppColors.textGrey,
                  ),
                  SizedBox(height: 12),
                  Text('No items in your wishlist'),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final product = items[index];
                return ProductCard(
                  product: product,
                  onTap: () =>
                      context.push(AppRoutes.productDetailPath(product.id)),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, st) => Center(child: Text('Failed to load wishlist')),
      ),
    );
  }
}
