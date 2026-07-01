import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../models/batch_model.dart';
import '../../../providers/batch_provider.dart';
import '../widgets/add_edit_batch_sheet.dart';

class BatchManagementScreen extends ConsumerStatefulWidget {
  const BatchManagementScreen({super.key});

  @override
  ConsumerState<BatchManagementScreen> createState() => _BatchManagementScreenState();
}

class _BatchManagementScreenState extends ConsumerState<BatchManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddBatchSheet([BatchModel? batch]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => AddEditBatchSheet(batch: batch),
    );
  }

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(filteredBatchesProvider);
    final allBatchesAsync = ref.watch(allBatchesProvider);
    final selectedStatus = ref.watch(batchStatusFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Manage Batches', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBatchSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Row
          allBatchesAsync.when(
            data: (allBatches) {
              final total = allBatches.length;
              final active = allBatches.where((b) => b.status == BatchStatus.active).length;
              final inactive = allBatches.where((b) => b.status == BatchStatus.inactive).length;
              final completed = allBatches.where((b) => b.status == BatchStatus.completed).length;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    _FilterChip(label: 'Total: $total', isSelected: selectedStatus == null, onTap: () => ref.read(batchStatusFilterProvider.notifier).state = null),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Active: $active', isSelected: selectedStatus == BatchStatus.active, onTap: () => ref.read(batchStatusFilterProvider.notifier).state = BatchStatus.active),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Inactive: $inactive', isSelected: selectedStatus == BatchStatus.inactive, onTap: () => ref.read(batchStatusFilterProvider.notifier).state = BatchStatus.inactive),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Completed: $completed', isSelected: selectedStatus == BatchStatus.completed, onTap: () => ref.read(batchStatusFilterProvider.notifier).state = BatchStatus.completed),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(height: 50),
            error: (_, __) => const SizedBox(height: 50),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => ref.read(batchSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search batch, subject, teacher...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: batchesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF97316))),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (batches) {
                if (batches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.class_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          ref.read(batchSearchQueryProvider).isEmpty && selectedStatus == null
                            ? 'No batches yet. Tap + to create your first batch.'
                            : 'No batches match your criteria',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: batches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final b = batches[index];
                    return _BatchCard(
                      batch: b,
                      onTap: () => context.push('/admin/batches/${b.id}'),
                      onEdit: () => _showAddBatchSheet(b),
                      onDelete: () => _confirmDelete(b),
                      onStatusChange: (status) async {
                        await ref.read(batchServiceProvider).updateStatus(b.id, status);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF97316),
        onPressed: _showAddBatchSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(BatchModel batch) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Batch?'),
        content: Text('Are you sure you want to delete ${batch.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(batchServiceProvider).deleteBatch(batch.id, batch.name);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Batch deleted')));
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF1E293B) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final BatchModel batch;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(BatchStatus) onStatusChange;

  const _BatchCard({
    required this.batch,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(batch.name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF1E293B))),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: batch.statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: BoxDecoration(color: batch.statusColor, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(batch.statusLabel, style: TextStyle(color: batch.statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                              padding: EdgeInsets.zero,
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'view', child: Text('View Students')),
                                if (batch.status != BatchStatus.inactive)
                                  const PopupMenuItem(value: 'inactive', child: Text('Mark as Inactive')),
                                if (batch.status != BatchStatus.completed)
                                  const PopupMenuItem(value: 'completed', child: Text('Mark as Completed')),
                                if (batch.status != BatchStatus.active)
                                  const PopupMenuItem(value: 'active', child: Text('Mark as Active')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                              onSelected: (val) {
                                if (val == 'edit') onEdit();
                                if (val == 'view') onTap();
                                if (val == 'delete') onDelete();
                                if (val == 'inactive') onStatusChange(BatchStatus.inactive);
                                if (val == 'completed') onStatusChange(BatchStatus.completed);
                                if (val == 'active') onStatusChange(BatchStatus.active);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('📚', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(batch.subject ?? 'No subject', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            const SizedBox(width: 12),
                            const Text('👨‍🏫', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(batch.teacherName ?? 'Unassigned', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('📅', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Expanded(child: Text(batch.scheduleDisplay, style: TextStyle(color: Colors.grey.shade600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('👥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text('${batch.currentStudentCount}/${batch.maxStudents} students', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const Text('💰', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text('₹${batch.feeAmount.toStringAsFixed(0)}/month', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: batch.occupancyPercentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: batch.isFull ? Colors.red : (batch.occupancyPercentage >= 70 ? Colors.orange : Colors.green),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('${batch.occupancyPercentage.toStringAsFixed(0)}% full', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      const Spacer(),
                      Text('🗓 ${batch.startDate?.toString().split(' ')[0] ?? '?'} → ${batch.endDate?.toString().split(' ')[0] ?? '?'}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
