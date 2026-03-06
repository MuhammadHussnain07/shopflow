// filepath: lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shopflow/core/router/app_router.dart';
import 'package:shopflow/core/theme/app_theme.dart';
import 'package:shopflow/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: currentUser.when(
        data: (user) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.splashGradient,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.accent,
                          child: Text(
                            user?.initials ?? 'U',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?.name ?? 'User',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Account',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ProfileMenuCard(
                      items: [
                        _MenuItem(
                          icon: Iconsax.receipt,
                          label: 'My Orders',
                          onTap: () => context.go(AppRoutes.orders),
                        ),
                        _MenuItem(
                          icon: Iconsax.heart,
                          label: 'Wishlist',
                          onTap: () => context.go(AppRoutes.wishlist),
                        ),
                        _MenuItem(
                          icon: Iconsax.location,
                          label: 'Saved Addresses',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ProfileMenuCard(
                      items: [
                        _MenuItem(
                          icon: Iconsax.notification,
                          label: 'Notifications',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Iconsax.lock,
                          label: 'Change Password',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Iconsax.shield_tick,
                          label: 'Privacy Policy',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Iconsax.info_circle,
                          label: 'About ShopFlow',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _ProfileMenuCard(
                      items: [
                        _MenuItem(
                          icon: Iconsax.logout,
                          label: 'Sign Out',
                          isDestructive: true,
                          onTap: () => _confirmSignOut(context, ref),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: GradientButton(
            text: 'Retry',
            width: 120,
            height: 44,
            onPressed: () => ref.invalidate(currentUserProvider),
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textGrey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(authNotifierProvider.notifier)
                  .signOut(context: context);
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

class _ProfileMenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _ProfileMenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? const Radius.circular(16) : Radius.zero,
                  bottom: isLast ? const Radius.circular(16) : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.isDestructive
                              ? AppColors.error.withValues(alpha: 0.1)
                              : AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.icon,
                          size: 18,
                          color: item.isDestructive
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: item.isDestructive
                                ? AppColors.error
                                : AppColors.textDark,
                          ),
                        ),
                      ),
                      if (!item.isDestructive)
                        const Icon(
                          Iconsax.arrow_right_3,
                          size: 16,
                          color: AppColors.textGrey,
                        ),
                    ],
                  ),
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 66),
            ],
          );
        }).toList(),
      ),
    );
  }
}
