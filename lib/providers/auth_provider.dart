// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/firebase_service.dart';
import '../core/services/notification_service.dart';
import '../models/user_model.dart';

// ── Raw Firebase auth stream ───────────────────────────────────────────────
final firebaseAuthStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseService.instance.authStateChanges;
});

// ── Current UserModel (resolved from Firestore) ───────────────────────────
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authAsync = ref.watch(firebaseAuthStreamProvider);
  return authAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirebaseService.instance.firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.exists
              ? UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)
              : null);
    },
    loading: () => const Stream.empty(),
    error:   (_, __) => Stream.value(null),
  );
});

// ── Auth state notifier ────────────────────────────────────────────────────
class AuthState {
  final bool   isLoading;
  final String? error;
  final bool   isPasswordResetSent;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isPasswordResetSent = false,
  });

  AuthState copyWith({bool? isLoading, String? error, bool? isPasswordResetSent}) =>
      AuthState(
        isLoading:           isLoading           ?? this.isLoading,
        error:               error,
        isPasswordResetSent: isPasswordResetSent ?? this.isPasswordResetSent,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  final _fb = FirebaseService.instance;

  // ── Sign In ──────────────────────────────────────────────────────────────
  Future<UserModel?> signIn({
    required String email,
    required String password,
    required UserRole expectedRole,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cred = await _fb.signInWithEmail(email.trim(), password);
      final uid  = cred.user!.uid;

      // Fetch user doc
      // Fetch user doc
      try {
        final doc = await _fb.users.doc(uid).get();
        if (!doc.exists) {
          await _fb.signOut();
          state = state.copyWith(isLoading: false, error: 'Account not found. Contact admin.');
          return null;
        }

        final user = UserModel.fromDoc(doc);

        // Role validation
        if (user.role != expectedRole) {
          await _fb.signOut();
          state = state.copyWith(
            isLoading: false,
            error: 'Access denied. You are not registered as ${expectedRole.name}.',
          );
          return null;
        }

        // Proceed with post-login steps using `user`
        // Remember Me
        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', email.trim());
          await prefs.setString('saved_role',  expectedRole.name);
        }

        // Save FCM token
        try {
          await NotificationService.instance.saveTokenToFirestore(uid);
        } catch (e) {
          debugPrint('Warning: failed to save FCM token: $e');
        }

        // Check installment reminders
        if (user.role == UserRole.student) {
          try {
            await NotificationService.instance
                .checkAndScheduleInstallmentReminders(uid);
          } catch (e) {
            debugPrint('Warning: failed to schedule installment reminders: $e');
          }
        }

        state = state.copyWith(isLoading: false);
        return user;
      } on FirebaseException catch (e) {
        debugPrint('Auth.signIn firestore error: ${e.code} ${e.message}');
        await _fb.signOut();
        final msg = e.code == 'permission-denied'
            ? 'Firestore access denied. Check Firestore rules for the `users` collection.'
            : (kDebugMode ? 'Firestore error: ${e.message}' : 'Something went wrong. Try again.');
        state = state.copyWith(isLoading: false, error: msg);
        return null;
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapAuthError(e.code));
      return null;
    } catch (e, st) {
      debugPrint('Auth.signIn unexpected error: $e\n$st');
      final message = kDebugMode ? 'Something went wrong: $e' : 'Something went wrong. Try again.';
      state = state.copyWith(isLoading: false, error: message);
      return null;
    }
  }

  // ── Sign Up ──────────────────────────────────────────────────────────────
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cred = await _fb.createUserWithEmail(email.trim(), password);
      final uid  = cred.user!.uid;

      final user = UserModel(
        uid: uid,
        email: email.trim(),
        name: name.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      // Save user to 'users' collection
      try {
        await _fb.setDoc('users', uid, user.toMap());

        // Optionally, add to role-specific collection (e.g. students, teachers, admins)
        await _fb.setDoc('${role.name}s', uid, user.toMap());

        // Save FCM token
        try {
          await NotificationService.instance.saveTokenToFirestore(uid);
        } catch (e) {
          debugPrint('Warning: failed to save FCM token (signUp): $e');
        }

        state = state.copyWith(isLoading: false);
        return user;
      } on FirebaseException catch (e) {
        debugPrint('Auth.signUp firestore error: ${e.code} ${e.message}');
        // Attempt to clean up created auth user to avoid orphaned accounts
        try {
          await cred.user?.delete();
        } catch (deleteErr) {
          debugPrint('Warning: failed to delete auth user after firestore failure: $deleteErr');
        }
        final msg = e.code == 'permission-denied'
            ? 'Firestore write denied. Check Firestore rules for the `users` collection.'
            : (kDebugMode ? 'Firestore error: ${e.message}' : 'Something went wrong. Try again.');
        state = state.copyWith(isLoading: false, error: msg);
        return null;
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapAuthError(e.code));
      return null;
    } catch (e, st) {
      debugPrint('Auth.signUp unexpected error: $e\n$st');
      final message = kDebugMode ? 'Something went wrong: $e' : 'Something went wrong. Try again.';
      state = state.copyWith(isLoading: false, error: message);
      return null;
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _fb.signOut();
    state = const AuthState();
  }

  // ── Forgot Password ───────────────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _fb.sendPasswordResetEmail(email.trim());
      state = state.copyWith(isLoading: false, isPasswordResetSent: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapAuthError(e.code));
    }
  }

  // ── Saved credentials ─────────────────────────────────────────────────────
  Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('saved_email'),
      'role':  prefs.getString('saved_role'),
    };
  }

  void clearError() => state = state.copyWith(error: null);

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':         return 'No account found with this email.';
      case 'wrong-password':         return 'Incorrect password. Try again.';
      case 'invalid-email':          return 'Invalid email address.';
      case 'user-disabled':          return 'This account has been disabled.';
      case 'too-many-requests':      return 'Too many attempts. Try again later.';
      case 'email-already-in-use':   return 'This email is already in use.';
      case 'weak-password':          return 'Password is too weak.';
      case 'operation-not-allowed':  return 'Email/password accounts are not enabled in Firebase.';
      case 'network-request-failed': return 'No internet connection.';
      case 'invalid-credential':     return 'Invalid credentials. Please check your email and password.';
      default:                       return 'Authentication failed ($code).';
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
