// lib/features/admin/screens/manage_teachers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/teacher_model.dart';
import '../../../providers/teacher_provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/loading_overlay.dart';
import '../../../widgets/premium_card.dart';

class ManageTeachersScreen extends ConsumerStatefulWidget {
  const ManageTeachersScreen({super.key});
  @override
  ConsumerState<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends ConsumerState<ManageTeachersScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final teachersAsync = ref.watch(allTeachersProvider);
    final adminState    = ref.watch(adminNotifierProvider);

    return LoadingOverlay(
      isLoading: adminState.isLoading,
      child: Scaffold(
        appBar: const GoldenAppBar(title: 'Manage Teachers'),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search teachers...',
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
            child: teachersAsync.when(
              loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (teachers) {
                final filtered = _query.isEmpty ? teachers
                    : teachers.where((t) =>
                        t.name.toLowerCase().contains(_query) ||
                        t.email.toLowerCase().contains(_query) ||
                        (t.subject ?? '').toLowerCase().contains(_query)).toList();

                if (filtered.isEmpty) {
                  return Center(
                  child: Text('No teachers found.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _TeacherTile(teacher: filtered[i])
                      .animate().fadeIn(delay: (i * 30).ms),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _TeacherTile extends StatelessWidget {
  final TeacherModel teacher;
  const _TeacherTile({required this.teacher});
  @override
  Widget build(BuildContext context) => PremiumCard(
    margin: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        backgroundImage: teacher.photoUrl != null ? CachedNetworkImageProvider(teacher.photoUrl!) : null,
        child: teacher.photoUrl == null
            ? Text(teacher.name[0].toUpperCase(),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w800))
            : null,
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(teacher.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        if (teacher.subject != null)
          Text(teacher.subject!, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
        Text(teacher.email, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 11)),
        if (teacher.batches.isNotEmpty)
          Text('Batches: ${teacher.batches.length}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 11)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: teacher.isActive ? Colors.green.withValues(alpha: 0.1) : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(teacher.isActive ? 'Active' : 'Inactive',
            style: TextStyle(
                color: teacher.isActive ? Colors.green : Theme.of(context).colorScheme.error,
                fontSize: 10, fontWeight: FontWeight.w700)),
      ),
    ]),
  );
}
