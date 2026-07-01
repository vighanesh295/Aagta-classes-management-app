import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/teacher_management_service.dart';
import '../models/teacher_model.dart';

final teacherManagementServiceProvider = Provider((ref) {
  return TeacherManagementService();
});

final allTeachersProvider = StreamProvider<List<TeacherModel>>((ref) {
  return ref.watch(teacherManagementServiceProvider).watchAllTeachers();
});

final teacherSearchQueryProvider = StateProvider<String>((ref) => '');

final teacherStatusFilterProvider = StateProvider<bool?>((ref) => null);

final filteredTeachersProvider = Provider<AsyncValue<List<TeacherModel>>>((ref) {
  final all = ref.watch(allTeachersProvider);
  final query = ref.watch(teacherSearchQueryProvider).toLowerCase();
  final isActive = ref.watch(teacherStatusFilterProvider);

  return all.whenData((teachers) {
    return teachers.where((t) {
      final matchesSearch = query.isEmpty ||
          t.name.toLowerCase().contains(query) ||
          (t.subject?.toLowerCase().contains(query) ?? false) ||
          (t.qualification?.toLowerCase().contains(query) ?? false);
      final matchesStatus = isActive == null || t.isActive == isActive;
      return matchesSearch && matchesStatus;
    }).toList();
  });
});
