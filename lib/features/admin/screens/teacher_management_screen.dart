import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/teacher_model.dart';
import '../../../providers/teacher_management_provider.dart';
import '../../../routes/app_router.dart';
import '../widgets/add_edit_teacher_sheet.dart';

class TeacherManagementScreen extends ConsumerWidget {
  const TeacherManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(filteredTeachersProvider);
    final allTeachersAsync = ref.watch(allTeachersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: const Text('Manage Teachers'),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => _showAddTeacherSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats & Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                _buildStatsRow(ref, allTeachersAsync),
                const SizedBox(height: 16),
                _buildSearchBar(ref),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Teachers List
          Expanded(
            child: teachersAsync.when(
              data: (teachers) {
                if (teachers.isEmpty) {
                  return const Center(child: Text('No teachers found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    return _TeacherCard(teacher: teacher);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF97316))),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTeacherSheet(context),
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsRow(WidgetRef ref, AsyncValue<List<TeacherModel>> allTeachersAsync) {
    final all = allTeachersAsync.valueOrNull ?? [];
    final active = all.where((t) => t.isActive).length;
    final inactive = all.length - active;
    
    final currentFilter = ref.watch(teacherStatusFilterProvider);

    return Row(
      children: [
        Expanded(child: _FilterChip(
          label: 'Total: ${all.length}',
          isSelected: currentFilter == null,
          onTap: () => ref.read(teacherStatusFilterProvider.notifier).state = null,
        )),
        const SizedBox(width: 8),
        Expanded(child: _FilterChip(
          label: 'Active: $active',
          isSelected: currentFilter == true,
          onTap: () => ref.read(teacherStatusFilterProvider.notifier).state = true,
          color: Colors.green,
        )),
        const SizedBox(width: 8),
        Expanded(child: _FilterChip(
          label: 'Inactive: $inactive',
          isSelected: currentFilter == false,
          onTap: () => ref.read(teacherStatusFilterProvider.notifier).state = false,
          color: Colors.grey,
        )),
      ],
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by name, subject, qualification...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onChanged: (val) => ref.read(teacherSearchQueryProvider.notifier).state = val,
    );
  }

  void _showAddTeacherSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddEditTeacherSheet(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color = const Color(0xFFF97316),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TeacherCard extends ConsumerWidget {
  final TeacherModel teacher;

  const _TeacherCard({required this.teacher});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/admin/teachers/${teacher.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF0D7377),
                  backgroundImage: teacher.photoUrl != null ? CachedNetworkImageProvider(teacher.photoUrl!) : null,
                  child: teacher.photoUrl == null ? Text(teacher.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              teacher.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: teacher.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 8, color: teacher.isActive ? Colors.green : Colors.grey),
                                const SizedBox(width: 4),
                                Text(teacher.isActive ? 'Active' : 'Inactive', style: TextStyle(color: teacher.isActive ? Colors.green : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          _buildPopupMenu(context, ref),
                        ],
                      ),
                      if (teacher.subject != null && teacher.subject!.isNotEmpty)
                        Row(
                          children: [
                            const Text('📚 ', style: TextStyle(fontSize: 14)),
                            Text(teacher.subject!, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (teacher.qualification != null || teacher.experienceYears > 0)
              Row(
                children: [
                  const Text('🎓 ', style: TextStyle(fontSize: 14)),
                  Text('${teacher.qualification ?? 'N/A'} • ${teacher.experienceDisplay}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            if (teacher.phone != null && teacher.phone!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Text('📞 ', style: TextStyle(fontSize: 14)),
                    Text(teacher.phone!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🏷 ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: teacher.assignedBatches.isEmpty
                        ? [const Text('No batches assigned', style: TextStyle(color: Colors.grey, fontSize: 12))]
                        : teacher.assignedBatches.map((b) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.3)),
                            ),
                            child: Text(b, style: const TextStyle(color: Color(0xFFEA580C), fontSize: 11, fontWeight: FontWeight.bold)),
                          )).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      padding: EdgeInsets.zero,
      onSelected: (val) async {
        final svc = ref.read(teacherManagementServiceProvider);
        if (val == 'edit') {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => AddEditTeacherSheet(teacher: teacher),
          );
        } else if (val == 'view') {
          context.push('/admin/teachers/${teacher.id}');
        } else if (val == 'toggle_status') {
          if (teacher.isActive) {
            await svc.deactivateTeacher(teacher.id);
          } else {
            await svc.reactivateTeacher(teacher.id);
          }
        } else if (val == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Teacher?'),
              content: const Text('This will permanently delete the teacher and remove them from all batches.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirm == true) {
            await svc.deleteTeacher(teacher.id);
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'view', child: Text('View Details')),
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(
          value: 'toggle_status',
          child: Text(teacher.isActive ? 'Deactivate' : 'Reactivate'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
