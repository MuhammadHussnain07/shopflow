// filepath: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shopflow/core/router/app_router.dart';
import 'package:shopflow/core/theme/app_theme.dart';
import 'package:shopflow/providers/auth_provider.dart';
import 'package:shopflow/providers/product_provider.dart';
// seed service removed (admin panel now handles seeding)
import 'package:shopflow/widgets/banner_slider.dart';
import 'package:shopflow/widgets/category_chips.dart';
import 'package:shopflow/widgets/product_card.dart';
import 'package:shopflow/widgets/shimmer_product_grid.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(
      productsByCategoryProvider(selectedCategory),
    );
    final currentUser = ref.watch(currentUserProvider);
    final scrollController = useScrollController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(productsByCategoryProvider(selectedCategory));
          ref.invalidate(categoriesProvider);
        },
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.white,
              elevation: 0,
              titleSpacing: 16,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, Color(0xFFFFA000)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'SF',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ShopFlow',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              actions: [
                // Seed button removed
                IconButton(
                  onPressed: () => context.go(AppRoutes.search),
                  icon: const Icon(
                    Iconsax.search_normal,
                    color: AppColors.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.profile),
                    child: currentUser.when(
                      data: (user) => CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user?.initials ?? 'U',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      loading: () => const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.shimmerBase,
                      ),
                      error: (error, stack) => const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Iconsax.user,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: currentUser.when(
                  data: (user) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user?.name.split(' ').first ?? 'there'} 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Discover your next favourite look',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Banner Slider
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 16),
                child: BannerSlider(),
              ),
            ),

            // Section title — Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  'Categories',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),

            // Category chips
            SliverToBoxAdapter(
              child: categoriesAsync.when(
                data: (categories) => CategoryChips(
                  categories: categories,
                  selected: selectedCategory,
                  onSelected: (cat) =>
                      ref.read(selectedCategoryProvider.notifier).state = cat,
                ),
                loading: () => const SizedBox(height: 48),
                error: (error, stack) => const SizedBox.shrink(),
              ),
            ),

            // Section title — Products
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCategory == 'All'
                          ? 'All Products'
                          : selectedCategory,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    productsAsync.when(
                      data: (products) => Text(
                        '${products.length} items',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (error, stack) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // Products grid
            productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _EmptyProducts(category: selectedCategory),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(
                        product: products[index],
                        onTap: () => context.push(
                          AppRoutes.productDetailPath(products[index].id),
                        ),
                      ),
                      childCount: products.length,
                    ),
                  ),
                );
              },
              loading: () =>
                  const SliverToBoxAdapter(child: ShimmerProductGrid()),
              error: (error, _) => SliverToBoxAdapter(
                child: _ErrorProducts(
                  onRetry: () => ref.invalidate(
                    productsByCategoryProvider(selectedCategory),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  final String category;
  const _EmptyProducts({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Iconsax.shopping_bag,
            size: 64,
            color: AppColors.textGrey.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No products in "$category"',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later or browse other categories.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textGrey.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorProducts extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorProducts({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Iconsax.warning_2,
            size: 64,
            color: AppColors.error.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load products',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          GradientButton(
            text: 'Retry',
            width: 120,
            height: 44,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
