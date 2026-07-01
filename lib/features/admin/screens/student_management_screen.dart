import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../providers/student_management_provider.dart';
import '../widgets/add_edit_student_sheet.dart';

class StudentManagementScreen extends ConsumerStatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  ConsumerState<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends ConsumerState<StudentManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddStudentSheet([dynamic student]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => AddEditStudentSheet(student: student),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(filteredStudentsProvider);
    final batchesAsync = ref.watch(batchesProvider);
    final selectedBatch = ref.watch(selectedBatchFilterProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Manage Students', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: _showAddStudentSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Filter row
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => ref.read(studentSearchQueryProvider.notifier).state = val,
                    decoration: InputDecoration(
                      hintText: 'Search name / roll...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: selectedBatch,
                        hint: Text('Batch', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Batches', style: TextStyle(fontSize: 14))),
                          ...batchesAsync.when(
                            data: (batches) => batches.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 14)))).toList(),
                            loading: () => [],
                            error: (_, __) => [],
                          ),
                        ],
                        onChanged: (val) => ref.read(selectedBatchFilterProvider.notifier).state = val,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats & List
          Expanded(
            child: studentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF97316))),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (students) {
                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          ref.read(studentSearchQueryProvider).isEmpty 
                            ? 'No students yet. Tap + to add.' 
                            : 'No students match your search',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final activeCount = students.where((s) => s.isActive).length;
                final inactiveCount = students.length - activeCount;

                return Column(
                  children: [
                    // Stats bar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text('Showing ${students.length} students', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          _StatChip(label: 'Total', count: students.length, color: Colors.blue),
                          const SizedBox(width: 8),
                          _StatChip(label: 'Active', count: activeCount, color: Colors.green),
                          const SizedBox(width: 8),
                          _StatChip(label: 'Inactive', count: inactiveCount, color: Colors.red),
                        ],
                      ),
                    ),

                    // Student list
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final s = students[index];
                          return _StudentCard(
                            student: s,
                            onTap: () {
                              context.push('/admin/students/${s.id}');
                            },
                            onEdit: () => _showAddStudentSheet(s),
                            onStatusChange: () async {
                              final svc = ref.read(studentManagementServiceProvider);
                              if (s.isActive) {
                                await svc.deactivateStudent(s.id);
                              } else {
                                await svc.reactivateStudent(s.id);
                              }
                            },
                            onDelete: () => _confirmDelete(s),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF97316),
        onPressed: _showAddStudentSheet,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(dynamic student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Student?'),
        content: const Text('Are you sure you want to remove this student?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _secondConfirmDelete(student);
            },
            child: const Text('Proceed', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _secondConfirmDelete(dynamic student) {
    final tc = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Final Confirmation', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This will permanently delete all data. Type student name to confirm.'),
            const SizedBox(height: 12),
            TextField(controller: tc, decoration: const InputDecoration(border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (tc.text.trim().toLowerCase() == student.name.toLowerCase()) {
                Navigator.pop(ctx);
                await ref.read(studentManagementServiceProvider).deleteStudent(student.id);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student deleted')));
              }
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final MaterialColor color;

  const _StatChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Text('$label: $count', style: TextStyle(color: color.shade700, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final dynamic student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onStatusChange;
  final VoidCallback onDelete;

  const _StudentCard({
    required this.student,
    required this.onTap,
    required this.onEdit,
    required this.onStatusChange,
    required this.onDelete,
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
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFF97316).withValues(alpha: 0.1),
              backgroundImage: student.photoUrl != null && student.photoUrl.toString().isNotEmpty
                  ? CachedNetworkImageProvider(student.photoUrl)
                  : null,
              child: student.photoUrl == null || student.photoUrl.toString().isEmpty
                  ? Text(student.initials, style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 18))
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (student.rollNumber != null) 
                        Text('Roll: ${student.rollNumber}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      if (student.batch != null) 
                        Text('Batch: ${student.batch}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (student.phone != null) ...[
                        const Icon(Icons.phone, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(student.phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: student.isActive ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(student.isActive ? 'Active' : 'Inactive', style: TextStyle(color: student.isActive ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (student.parentName != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.family_restroom, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Parent: ${student.parentName}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Menu
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'status', child: Text(student.isActive ? 'Deactivate' : 'Reactivate')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'status') onStatusChange();
                if (val == 'delete') onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
