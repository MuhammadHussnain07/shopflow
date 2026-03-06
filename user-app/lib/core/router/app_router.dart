// filepath: lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopflow/providers/auth_provider.dart';
import 'package:shopflow/screens/cart_screen.dart';
import 'package:shopflow/screens/checkout_screen.dart';
import 'package:shopflow/screens/home_screen.dart';
import 'package:shopflow/screens/login_screen.dart';
import 'package:shopflow/screens/onboarding_screen.dart';
import 'package:shopflow/screens/order_success_screen.dart';
import 'package:shopflow/screens/orders_screen.dart';
import 'package:shopflow/screens/product_detail_screen.dart';
import 'package:shopflow/screens/profile_screen.dart';
import 'package:shopflow/screens/wishlist_screen.dart';
import 'package:shopflow/screens/register_screen.dart';
import 'package:shopflow/screens/search_screen.dart';
import 'package:shopflow/screens/splash_screen.dart';
import 'package:shopflow/widgets/bottom_nav_bar.dart';

// Route name constants
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String wishlist = '/wishlist';
  static const String productDetail = '/product/:productId';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';

  static String productDetailPath(String productId) => '/product/$productId';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.value != null;
      final location = state.matchedLocation;

      final isAuthRoute =
          location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.onboarding ||
          location == AppRoutes.splash;

      if (authState.isLoading) return null;

      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (isLoggedIn &&
          (location == AppRoutes.login || location == AppRoutes.register)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) =>
            _buildSlideUpPage(state: state, child: const RegisterScreen()),
      ),

      // Shell route for bottom nav screens
      ShellRoute(
        builder: (context, state, child) {
          return BottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) =>
                _buildPage(state: state, child: const HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            pageBuilder: (context, state) =>
                _buildPage(state: state, child: const SearchScreen()),
          ),
          GoRoute(
            path: AppRoutes.cart,
            name: 'cart',
            pageBuilder: (context, state) =>
                _buildPage(state: state, child: const CartScreen()),
          ),
          GoRoute(
            path: AppRoutes.orders,
            name: 'orders',
            pageBuilder: (context, state) =>
                _buildPage(state: state, child: const OrdersScreen()),
          ),
          GoRoute(
            path: AppRoutes.wishlist,
            name: 'wishlist',
            pageBuilder: (context, state) =>
                _buildPage(state: state, child: const WishlistScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) =>
                _buildPage(state: state, child: const ProfileScreen()),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.productDetail,
        name: 'productDetail',
        pageBuilder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return _buildPage(
            state: state,
            child: ProductDetailScreen(productId: productId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        pageBuilder: (context, state) =>
            _buildSlideUpPage(state: state, child: const CheckoutScreen()),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        name: 'orderSuccess',
        pageBuilder: (context, state) =>
            _buildPage(state: state, child: const OrderSuccessScreen()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

CustomTransitionPage<void> _buildPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _buildSlideUpPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
