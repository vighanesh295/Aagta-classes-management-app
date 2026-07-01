import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/batch_model.dart';
import '../core/services/batch_service.dart';

final batchServiceProvider = Provider((_) => BatchService());

// All batches stream
final allBatchesProvider = StreamProvider<List<BatchModel>>((ref) {
  return ref.watch(batchServiceProvider).watchAllBatches();
});

// Active batches only
final activeBatchesProvider = StreamProvider<List<BatchModel>>((ref) {
  return ref.watch(batchServiceProvider).watchActiveBatches();
});

// Status filter state
final batchStatusFilterProvider = StateProvider<BatchStatus?>((ref) => null);

// Search query
final batchSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered batches
final filteredBatchesProvider = Provider<AsyncValue<List<BatchModel>>>((ref) {
  final all = ref.watch(allBatchesProvider);
  final query = ref.watch(batchSearchQueryProvider).toLowerCase();
  final status = ref.watch(batchStatusFilterProvider);

  return all.whenData((batches) {
    return batches.where((b) {
      final matchesSearch = query.isEmpty ||
          b.name.toLowerCase().contains(query) ||
          (b.subject?.toLowerCase().contains(query) ?? false) ||
          (b.teacherName?.toLowerCase().contains(query) ?? false);
      final matchesStatus = status == null || b.status == status;
      return matchesSearch && matchesStatus;
    }).toList();
  });
});
