// filepath: lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopflow/core/router/app_router.dart';
import 'package:shopflow/core/theme/app_theme.dart';

class _OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
  });
}

const _pages = [
  _OnboardingPage(
    title: 'Discover Fashion, That Fits You',
    subtitle:
        'Explore thousands of curated styles from top brands, tailored to your unique taste and personality.',
    icon: Icons.checkroom_rounded,
    gradientColors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  ),
  _OnboardingPage(
    title: 'Shop Smarter, Not Harder',
    subtitle:
        'Lightning-fast checkout, real-time order tracking, and hassle-free returns — all in one place.',
    icon: Icons.shopping_bag_rounded,
    gradientColors: [Color(0xFF16213E), Color(0xFF0F3460)],
  ),
  _OnboardingPage(
    title: 'Your Style,Delivered Fast',
    subtitle:
        'Get your favourite fashion pieces delivered straight to your door. Express shipping available.',
    icon: Icons.local_shipping_rounded,
    gradientColors: [Color(0xFF0F3460), Color(0xFF1A1A2E)],
  ),
];

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentPage = useState(0);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => currentPage.value = index,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _OnboardingPageView(page: page, size: size);
            },
          ),

          // Top skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: currentPage.value < _pages.length - 1
                ? TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage.value == index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage.value == index
                              ? AppColors.accent
                              : AppColors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action button
                  GradientButton(
                    text: currentPage.value == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: () {
                      if (currentPage.value == _pages.length - 1) {
                        context.go(AppRoutes.login);
                      } else {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  final Size size;

  const _OnboardingPageView({required this.page, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: page.gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.15,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 80),

                // Icon container
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, Color(0xFFFFA000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(page.icon, size: 44, color: AppColors.primary),
                ),

                const SizedBox(height: 48),

                // Title
                Text(
                  page.title,
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 20),

                // Accent line
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, Color(0xFFFFA000)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 20),

                // Subtitle
                Text(
                  page.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white.withValues(alpha: 0.75),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
