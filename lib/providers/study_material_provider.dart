import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/study_material_model.dart';
import '../core/services/study_material_service.dart';
import '../../providers/auth_provider.dart';

final studyMaterialServiceProvider = Provider((_) => StudyMaterialService());

// For students — filtered by their batch
final studentMaterialsProvider = StreamProvider<List<StudyMaterialModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user?.batch == null) return const Stream.empty();
  return ref.watch(studyMaterialServiceProvider).watchMaterials(user!.batch!);
});

// For admin/teacher — all materials
final allMaterialsProvider = StreamProvider<List<StudyMaterialModel>>((ref) {
  return ref.watch(studyMaterialServiceProvider).watchAllMaterials();
});

// Upload state
final uploadProgressProvider = StateProvider<double?>((ref) => null);
