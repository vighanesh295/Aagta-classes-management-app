import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/announcement_service.dart';
import '../models/announcement_model.dart';
import 'auth_provider.dart';

final announcementServiceProvider = Provider((ref) => AnnouncementService());

final announcementsProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return ref.watch(announcementServiceProvider).watchAnnouncements(user?.batch);
});
