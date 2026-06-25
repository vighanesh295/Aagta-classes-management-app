// lib/core/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient client = Supabase.instance.client;
  final GoTrueClient   auth   = Supabase.instance.client.auth;
  final SupabaseStorageClient storage = Supabase.instance.client.storage;

  // ── Database Table References ────────────────────────────────────────
  SupabaseQueryBuilder get users          => client.from('users');
  SupabaseQueryBuilder get students       => client.from('students');
  SupabaseQueryBuilder get teachers       => client.from('teachers');
  SupabaseQueryBuilder get admins         => client.from('admins');
  SupabaseQueryBuilder get fees           => client.from('fees');
  SupabaseQueryBuilder get installments   => client.from('installments');
  SupabaseQueryBuilder get attendance     => client.from('attendance');
  SupabaseQueryBuilder get lectures       => client.from('lectures');
  SupabaseQueryBuilder get notifications  => client.from('notifications');
  SupabaseQueryBuilder get studyMaterials => client.from('study_materials');
  SupabaseQueryBuilder get results        => client.from('results');
  SupabaseQueryBuilder get announcements  => client.from('announcements');
  SupabaseQueryBuilder get batches        => client.from('batches');
  SupabaseQueryBuilder get homework       => client.from('homework');

  // ── Auth Helpers ────────────────────────────────────────────────────────────
  User? get currentUser => auth.currentUser;
  String? get currentUid => auth.currentUser?.id;

  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> createUserWithEmail(String email, String password) async {
    return auth.signUp(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    return auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async => auth.signOut();

  // ── Database Helpers (Simple Abstractions) ──────────────────────────────────
  Future<Map<String, dynamic>?> getDoc(String table, String id) async {
    final response = await client.from(table).select().eq('id', id).maybeSingle();
    return response;
  }

  Future<void> setDoc(
    String table, String id, Map<String, dynamic> data, {
    bool merge = false,
  }) async {
     data['id'] = id; // Ensure ID is in payload for upsert
     await client.from(table).upsert(data);
  }

  Future<void> updateDoc(String table, String id, Map<String, dynamic> data) async {
     await client.from(table).update(data).eq('id', id);
  }

  Future<void> deleteDoc(String table, String id) async {
     await client.from(table).delete().eq('id', id);
  }


}
