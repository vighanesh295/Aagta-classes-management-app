import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/announcement_model.dart';

class AnnouncementService {
  final _client = Supabase.instance.client;

  // Stream all announcements visible to current user (global + their batch)
  Stream<List<AnnouncementModel>> watchAnnouncements(String? userBatch) {
    return _client
        .from('announcements')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) {
          // In Dart we filter after fetching stream, though RLS does most of the job.
          // RLS ensures they only see global and their batch, so we just map it.
          return rows.map((row) => AnnouncementModel.fromMap(row)).toList();
        });
  }

  // Admin/Teacher: create announcement
  Future<void> createAnnouncement(AnnouncementModel model) async {
    await _client.from('announcements').insert(model.toMap());
    // Edge function trigger handles push notification
  }

  // Admin only: pin/unpin announcement
  Future<void> togglePin(String id, bool isPinned) async {
    await _client.from('announcements')
        .update({'is_pinned': isPinned}).eq('id', id);
  }

  // Admin or creator: delete announcement
  Future<void> delete(String id) async {
    await _client.from('announcements').delete().eq('id', id);
  }
}
