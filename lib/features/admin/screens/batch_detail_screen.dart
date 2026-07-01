import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/batch_model.dart';
import '../../../models/student_model.dart';
import '../../../providers/batch_provider.dart';
import '../../../providers/student_management_provider.dart';
import '../widgets/add_edit_batch_sheet.dart';

// Provider to fetch students for a specific batch name
final batchStudentsProvider = FutureProvider.family<List<StudentModel>, String>((ref, batchName) {
  return ref.watch(batchServiceProvider).fetchStudentsInBatch(batchName);
});

class BatchDetailScreen extends ConsumerStatefulWidget {
  final String batchId;
  const BatchDetailScreen({super.key, required this.batchId});

  @override
  ConsumerState<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends ConsumerState<BatchDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(allBatchesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Batch Details', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: batchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF97316))),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (batches) {
          final batchList = batches.where((b) => b.id == widget.batchId).toList();
          if (batchList.isEmpty) return const Center(child: Text('Batch not found'));
          final batch = batchList.first;

          return Column(
            children: [
              // Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(batch.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 24, color: const Color(0xFF1E293B)))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: batch.statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(batch.statusLabel, style: TextStyle(color: batch.statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text('📚 ${batch.subject ?? "No Subject"}', style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFFF97316),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFFF97316),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Students'),
                    Tab(text: 'Schedule'),
                  ],
                ),
              ),

              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(batch),
                    _buildStudentsTab(batch),
                    _buildScheduleTab(batch),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(BatchModel batch) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Teacher Assigned',
            Icons.person,
            batch.teacherName ?? 'Unassigned',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            'Fee Amount',
            Icons.payments,
            '₹${batch.feeAmount.toStringAsFixed(0)} / month',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            'Duration',
            Icons.calendar_month,
            '${batch.startDate?.toString().split(' ')[0] ?? '?'} to ${batch.endDate?.toString().split(' ')[0] ?? '?'}',
          ),
          const SizedBox(height: 12),
          // Occupancy Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people, color: Color(0xFFF97316), size: 20),
                    const SizedBox(width: 8),
                    Text('Occupancy', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                    const Spacer(),
                    Text('${batch.currentStudentCount} / ${batch.maxStudents}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: batch.occupancyPercentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: batch.isFull ? Colors.red : (batch.occupancyPercentage >= 70 ? Colors.orange : Colors.green),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          if (batch.description != null && batch.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoCard('Description', Icons.description, batch.description!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFF97316), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab(BatchModel batch) {
    final studentsAsync = ref.watch(batchStudentsProvider(batch.name));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddExistingStudentDialog(batch.name),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Existing Student to Batch'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: const Color(0xFFF97316),
              elevation: 0,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        Expanded(
          child: studentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (students) {
              if (students.isEmpty) {
                return Center(
                  child: Text('No students in this batch yet.', style: TextStyle(color: Colors.grey.shade500)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: students.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final s = students[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFF97316).withValues(alpha: 0.1),
                          backgroundImage: s.photoUrl != null && s.photoUrl!.isNotEmpty ? CachedNetworkImageProvider(s.photoUrl!) : null,
                          child: s.photoUrl == null || s.photoUrl!.isEmpty
                              ? Text(s.initials, style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold))
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              if (s.rollNumber != null)
                                Text('Roll: ${s.rollNumber}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _showMoveStudentDialog(s, batch.name),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFF97316),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFF97316)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text('Move', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddExistingStudentDialog(String currentBatchName) async {
    // Basic search dialog approach to find unassigned or students from other batches
    // For simplicity, reusing filteredStudentsProvider
    showDialog(
      context: context,
      builder: (ctx) => _AddStudentDialog(currentBatchName: currentBatchName),
    ).then((_) {
      ref.invalidate(batchStudentsProvider(currentBatchName));
    });
  }

  void _showMoveStudentDialog(StudentModel student, String currentBatchName) async {
    final activeBatchesAsync = ref.read(activeBatchesProvider);
    final activeBatches = activeBatchesAsync.valueOrNull ?? [];
    final availableBatches = activeBatches.where((b) => b.name != currentBatchName).toList();

    String? selectedBatchName;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Move Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Move ${student.name} to another batch:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedBatchName,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Select Batch'),
                items: availableBatches.map((b) => DropdownMenuItem(value: b.name, child: Text(b.name))).toList(),
                onChanged: (val) => setState(() => selectedBatchName = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: selectedBatchName == null ? null : () async {
                Navigator.pop(ctx);
                try {
                  await ref.read(batchServiceProvider).moveStudentToBatch(studentId: student.id, newBatchName: selectedBatchName!);
                  ref.invalidate(batchStudentsProvider(currentBatchName));
                  ref.invalidate(batchStudentsProvider(selectedBatchName!));
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student moved successfully')));
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTab(BatchModel batch) {
    final allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: allDays.map((day) {
                final isActive = batch.scheduleDays.contains(day);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 40, child: Text(day, style: TextStyle(fontWeight: FontWeight.w600, color: isActive ? const Color(0xFF1E293B) : Colors.grey))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFFF97316) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: isActive 
                            ? Text(batch.scheduleTime ?? 'Time Not Set', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                            : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (ctx) => AddEditBatchSheet(batch: batch),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Edit Batch', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (batch.status != BatchStatus.completed)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref.read(batchServiceProvider).updateStatus(batch.id, BatchStatus.completed);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Mark as Completed'),
                  ),
                ),
              if (batch.status != BatchStatus.completed && batch.status != BatchStatus.inactive)
                const SizedBox(width: 12),
              if (batch.status != BatchStatus.inactive)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref.read(batchServiceProvider).updateStatus(batch.id, BatchStatus.inactive);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade200),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Mark as Inactive'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Dialog for adding existing student
class _AddStudentDialog extends ConsumerStatefulWidget {
  final String currentBatchName;
  const _AddStudentDialog({required this.currentBatchName});
  @override
  ConsumerState<_AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends ConsumerState<_AddStudentDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    // Get all students using the service directly or via a provider
    final studentsAsync = ref.watch(allStudentsProvider);

    return AlertDialog(
      title: const Text('Add Existing Student'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Search by name...', prefixIcon: Icon(Icons.search)),
              onChanged: (val) => setState(() => _query = val.toLowerCase()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: studentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (allStudents) {
                  final filtered = allStudents.where((s) => 
                    s.batch != widget.currentBatchName && 
                    s.name.toLowerCase().contains(_query)
                  ).toList();

                  if (filtered.isEmpty) return const Center(child: Text('No students found.'));

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final s = filtered[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(s.initials)),
                        title: Text(s.name),
                        subtitle: Text(s.batch ?? 'Unassigned'),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            try {
                              await ref.read(batchServiceProvider).moveStudentToBatch(studentId: s.id, newBatchName: widget.currentBatchName);
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          },
                          child: const Text('Add'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
