import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/student_model.dart';
import '../core/services/student_management_service.dart';

final studentManagementServiceProvider = Provider((_) => StudentManagementService());

// All students stream
final allStudentsProvider = StreamProvider<List<StudentModel>>((ref) {
  return ref.watch(studentManagementServiceProvider).watchAllStudents();
});

// Selected batch filter state
final selectedBatchFilterProvider = StateProvider<String?>((ref) => null);

// Search query state
final studentSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered students (derived from allStudents + search + batch filter)
final filteredStudentsProvider = Provider<AsyncValue<List<StudentModel>>>((ref) {
  final allStudents = ref.watch(allStudentsProvider);
  final query = ref.watch(studentSearchQueryProvider).toLowerCase();
  final batch = ref.watch(selectedBatchFilterProvider);

  return allStudents.whenData((students) {
    return students.where((s) {
      final matchesSearch = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          (s.rollNumber?.toLowerCase().contains(query) ?? false) ||
          s.email.toLowerCase().contains(query);
      final matchesBatch = batch == null || s.batch == batch;
      return matchesSearch && matchesBatch;
    }).toList();
  });
});

// Batches list for filter dropdown
final batchesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(studentManagementServiceProvider).fetchBatches();
});
