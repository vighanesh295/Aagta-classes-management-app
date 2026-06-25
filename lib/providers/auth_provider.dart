// lib/providers/auth_provider.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/supabase_service.dart';
import '../core/services/notification_service.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/teacher_model.dart';

// ── Raw Supabase auth stream ───────────────────────────────────────────────
final supabaseAuthStreamProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.instance.authStateChanges;
});

// ── Current UserModel (resolved from Supabase DB) ─────────────────────────
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authAsync = ref.watch(supabaseAuthStreamProvider);
  return authAsync.when(
    data: (authState) {
      final user = authState.session?.user;
      if (user == null) return Stream.value(null);
      // Supabase stream for single row:
      return SupabaseService.instance.client
          .from('users')
          .stream(primaryKey: ['id'])
          .eq('id', user.id)
          .map((rows) => rows.isNotEmpty
              ? UserModel.fromMap(rows.first, user.id)
              : null);
    },
    loading: () => const Stream.empty(),
    error:   (_, __) => Stream.value(null),
  );
});

// ── Auth state notifier ────────────────────────────────────────────────────
class AppAuthState {
  final bool   isLoading;
  final String? error;
  final bool   isPasswordResetSent;

  const AppAuthState({
    this.isLoading = false,
    this.error,
    this.isPasswordResetSent = false,
  });

  AppAuthState copyWith({bool? isLoading, String? error, bool? isPasswordResetSent}) =>
      AppAuthState(
        isLoading:           isLoading           ?? this.isLoading,
        error:               error,
        isPasswordResetSent: isPasswordResetSent ?? this.isPasswordResetSent,
      );
}

class AuthNotifier extends StateNotifier<AppAuthState> {
  AuthNotifier() : super(const AppAuthState());

  final _supabase = SupabaseService.instance;

  // ── Sign In ──────────────────────────────────────────────────────────────
  Future<UserModel?> signIn({
    required String email,
    required String password,
    required UserRole expectedRole,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _supabase.signInWithEmail(email.trim(), password);
      final uid = response.user?.id;
      if (uid == null) {
        state = state.copyWith(isLoading: false, error: 'Login failed. Try again.');
        return null;
      }

      // Fetch user doc
      try {
        final doc = await _supabase.getDoc('users', uid);
        if (doc == null) {
          await _supabase.signOut();
          state = state.copyWith(isLoading: false, error: 'Account not found. Contact admin.');
          return null;
        }

        final user = UserModel.fromMap(doc, uid);

        // Role validation
        if (user.role != expectedRole) {
          await _supabase.signOut();
          state = state.copyWith(
            isLoading: false,
            error: 'Access denied. You are not registered as ${expectedRole.name}.',
          );
          return null;
        }

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
      } catch (e) {
        debugPrint('Auth.signIn database error: $e');
        await _supabase.signOut();
        state = state.copyWith(isLoading: false, error: 'Database error. Try again.');
        return null;
      }
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapAuthError(e.message));
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
      final response = await _supabase.createUserWithEmail(email.trim(), password);
      final uid = response.user?.id;
      if (uid == null) {
        state = state.copyWith(isLoading: false, error: 'Signup failed. Try again.');
        return null;
      }

      final user = UserModel(
        uid: uid,
        email: email.trim(),
        name: name.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      try {
        await _supabase.setDoc('users', uid, user.toMap());
        
        if (role == UserRole.student) {
          final student = StudentModel(
            uid: uid,
            name: name.trim(),
            email: email.trim(),
            studentId: 'STU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            enrolledAt: DateTime.now(),
          );
          await _supabase.setDoc('students', uid, student.toMap());
        } else if (role == UserRole.teacher) {
          final teacher = TeacherModel(
            uid: uid,
            name: name.trim(),
            email: email.trim(),
            joinedAt: DateTime.now(),
          );
          await _supabase.setDoc('teachers', uid, teacher.toMap());
        }

        try {
          await NotificationService.instance.saveTokenToFirestore(uid);
        } catch (e) {
          debugPrint('Warning: failed to save FCM token (signUp): $e');
        }

        state = state.copyWith(isLoading: false);
        return user;
      } catch (e) {
        debugPrint('Auth.signUp database error: $e');
        state = state.copyWith(isLoading: false, error: 'Database error. Try again.');
        return null;
      }
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapAuthError(e.message));
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
    await _supabase.signOut();
    state = const AppAuthState();
  }

  // ── Forgot Password ───────────────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.sendPasswordResetEmail(email.trim());
      state = state.copyWith(isLoading: false, isPasswordResetSent: true);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapAuthError(e.message));
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

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (message.contains('User already registered')) {
      return 'This email is already in use.';
    }
    return message;
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AppAuthState>((ref) => AuthNotifier());
