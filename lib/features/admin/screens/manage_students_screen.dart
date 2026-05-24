// lib/features/admin/screens/manage_students_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/student_model.dart';
import '../../../providers/student_provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/loading_overlay.dart';
import '../../../widgets/premium_card.dart';

class ManageStudentsScreen extends ConsumerStatefulWidget {
  const ManageStudentsScreen({super.key});
  @override
  ConsumerState<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends ConsumerState<ManageStudentsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsProvider);
    final adminState    = ref.watch(adminNotifierProvider);

    return LoadingOverlay(
      isLoading: adminState.isLoading,
      child: Scaffold(
        appBar: const GoldenAppBar(title: 'Manage Students'),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: studentsAsync.when(
              loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (students) {
                final filtered = _query.isEmpty
                    ? students
                    : students.where((s) =>
                        s.name.toLowerCase().contains(_query) ||
                        s.email.toLowerCase().contains(_query) ||
                        s.studentId.toLowerCase().contains(_query)).toList();

                if (filtered.isEmpty) {
                  return Center(
                  child: Text('No students found.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final s = filtered[i];
                    return _StudentTile(
                      student: s,
                      onDelete: () => _confirmDelete(context, s),
                    ).animate().fadeIn(delay: (i * 30).ms);
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, StudentModel s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to remove ${s.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(adminNotifierProvider.notifier).deleteStudent(s.uid);
    }
  }
}

class _StudentTile extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onDelete;
  const _StudentTile({required this.student, required this.onDelete});

  @override
  Widget build(BuildContext context) => PremiumCard(
    margin: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        backgroundImage: student.photoUrl != null ? NetworkImage(student.photoUrl!) : null,
        child: student.photoUrl == null
            ? Text(student.name[0].toUpperCase(), style: TextStyle(
                color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w800))
            : null,
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(student.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        Text('ID: ${student.studentId}  Â·  ${student.batchName ?? "No batch"}',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 11)),
        Text(student.email, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 11)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: student.isActive ? Colors.green.withValues(alpha: 0.1) : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(student.isActive ? 'Active' : 'Inactive',
            style: TextStyle(
                color: student.isActive ? Colors.green : Theme.of(context).colorScheme.error,
                fontSize: 10, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 4),
      IconButton(
        icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error, size: 20),
        onPressed: onDelete,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(4),
      ),
    ]),
  );
}
