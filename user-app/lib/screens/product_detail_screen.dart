// filepath: lib/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shopflow/core/theme/app_theme.dart';

import 'package:shopflow/providers/cart_provider.dart' as cart;
import 'package:shopflow/providers/product_provider.dart' as product;

class ProductDetailScreen extends HookConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(product.productByIdProvider(productId));

    final quantity = useState(1);
    final wishlist = ref.watch(product.wishlistProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: productAsync.when(
        data: (productData) {
          if (productData == null) {
            return const Center(child: Text('Product not found'));
          }

          final isWishlisted = wishlist.contains(productData.id);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: AppColors.white,
                leading: IconButton(
                  icon: const Icon(Iconsax.arrow_left),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isWishlisted ? Iconsax.heart5 : Iconsax.heart,
                      color: isWishlisted ? Colors.red : AppColors.primary,
                    ),
                    onPressed: () => ref
                        .read(product.wishlistProvider.notifier)
                        .toggle(productData.id),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'product_${productData.id}',
                    child: CachedNetworkImage(
                      imageUrl: productData.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (c, u) =>
                          Container(color: AppColors.shimmerBase),
                      errorWidget: (c, u, e) => Container(
                        color: AppColors.background,
                        child: const Icon(
                          Iconsax.image,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productData.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '\$${productData.price.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Iconsax.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            productData.rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            productData.stock > 0 ? 'In stock' : 'Out of stock',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: productData.stock > 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        productData.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quantity selector + Add to cart
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.white,
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (quantity.value > 1) quantity.value -= 1;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(Iconsax.minus, size: 16),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    '${quantity.value}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (quantity.value < productData.stock) {
                                      quantity.value += 1;
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(Iconsax.add, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GradientButton(
                              text: 'Add to Cart',
                              icon: Iconsax.shopping_cart,
                              onPressed: productData.stock == 0
                                  ? null
                                  : () => ref
                                        .read(
                                          cart.cartNotifierProvider.notifier,
                                        )
                                        .addToCart(
                                          productId: productData.id,
                                          productName: productData.name,
                                          price: productData.price,
                                          imageUrl: productData.imageUrl,
                                          quantity: quantity.value,
                                          context: context,
                                        ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: ElevatedButton(
            onPressed: () =>
                ref.invalidate(product.productByIdProvider(productId)),
            child: const Text("Retry"),
          ),
        ),
      ),
    );
  }
}
