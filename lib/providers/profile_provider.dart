// lib/providers/profile_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  const ProfileState({this.isLoading = false, this.error});
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this.ref) : super(const ProfileState());

  final Ref ref;

  Future<void> updateProfile({
    File? imageFile,
    String? phone,
    String? batchName,
  }) async {
    state = const ProfileState(isLoading: true);
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) throw Exception('No user logged in');

      String? photoUrl = user.photoUrl;

      if (imageFile != null && await imageFile.exists()) {
        final storage = SupabaseService.instance.client.storage.from('profile_images');
        final fileName = '${user.uid}.jpg';
        
        final bytes = await imageFile.readAsBytes();
        
        try {
          await storage.uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
          
          photoUrl = storage.getPublicUrl(fileName);
        } catch (e) {
          throw Exception('Image upload failed: $e');
        }
      }

      // Update users collection
      final updateData = <String, dynamic>{};
      if (photoUrl != null) updateData['photo_url'] = photoUrl;
      if (phone != null) updateData['phone'] = phone;

      if (updateData.isNotEmpty) {
        await SupabaseService.instance.updateDoc('users', user.uid, updateData);
      }

      // Update role-specific collection
      final roleUpdateData = Map<String, dynamic>.from(updateData);
      if (batchName != null && batchName.isNotEmpty && user.role != UserRole.admin) {
        roleUpdateData['batch_name'] = batchName;
      }
      
      if (roleUpdateData.isNotEmpty) {
        await SupabaseService.instance.updateDoc('${user.role.name}s', user.uid, roleUpdateData);
      }

      state = const ProfileState(isLoading: false);
    } catch (e) {
      state = ProfileState(isLoading: false, error: e.toString());
    }
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});
