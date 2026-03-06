// filepath: lib/providers/auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopflow/models/user_model.dart';
import 'package:shopflow/services/auth_service.dart';

/// 🔹 Auth service singleton provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// 🔹 Firebase auth state stream — drives go_router auth guard
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// 🔹 Currently signed-in Firebase user (nullable)
final currentFirebaseUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// 🔹 Currently signed-in user's UID (nullable)
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentFirebaseUserProvider)?.uid;
});

/// 🔹 Full UserModel from Firestore for current user
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(currentUserIdProvider);

  if (uid == null) {
    return Stream.value(null);
  }

  // Directly return profile stream from service
  return ref.watch(authServiceProvider).userProfileStream(uid);
});

/// 🔹 Auth loading state notifier
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        context: context,
      );
      state = const AsyncValue.data(null);
      return user != null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signIn(
        email: email,
        password: password,
        context: context,
      );
      state = const AsyncValue.data(null);
      return user != null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> signOut({BuildContext? context}) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut(context: context);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
    BuildContext? context,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await _authService.updateUserProfile(
        uid: uid,
        data: data,
        context: context,
      );
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> sendPasswordReset({
    required String email,
    BuildContext? context,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await _authService.sendPasswordResetEmail(
        email: email,
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

/// 🔹 StateNotifier provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
      return AuthNotifier(ref.watch(authServiceProvider));
    });

/// 🔹 Quick bool auth check
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentFirebaseUserProvider) != null;
});
