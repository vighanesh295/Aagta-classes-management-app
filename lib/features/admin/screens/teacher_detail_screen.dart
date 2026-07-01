import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/teacher_model.dart';
import '../../../providers/teacher_management_provider.dart';
import '../widgets/add_edit_teacher_sheet.dart';

class TeacherDetailScreen extends ConsumerStatefulWidget {
  final String teacherId;

  const TeacherDetailScreen({super.key, required this.teacherId});

  @override
  ConsumerState<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends ConsumerState<TeacherDetailScreen> with SingleTickerProviderStateMixin {
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
    final allAsync = ref.watch(allTeachersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: const Text('Teacher Details'),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
      ),
      body: allAsync.when(
        data: (teachers) {
          final teacher = teachers.firstWhere((t) => t.id == widget.teacherId, 
              orElse: () => TeacherModel(id: '', name: 'Not Found', email: ''));
          
          if (teacher.id.isEmpty) {
            return const Center(child: Text('Teacher not found'));
          }

          return Column(
            children: [
              _buildHeroSection(context, teacher),
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFF97316),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFFF97316),
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Batches'),
                  Tab(text: 'Schedule'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(teacher),
                    _buildBatchesTab(context, ref, teacher),
                    _buildScheduleTab(teacher), // Simplified for now since schedule logic involves fetching lectures which might need a different provider
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF97316))),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, TeacherModel teacher) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF0D7377),
            backgroundImage: teacher.photoUrl != null ? CachedNetworkImageProvider(teacher.photoUrl!) : null,
            child: teacher.photoUrl == null ? Text(teacher.initials, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)) : null,
          ),
          const SizedBox(height: 16),
          Text(teacher.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (teacher.subject != null && teacher.subject!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF0D7377).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(teacher.subject!, style: const TextStyle(color: Color(0xFF0D7377), fontWeight: FontWeight.bold)),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: teacher.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(teacher.isActive ? 'Active' : 'Inactive', style: TextStyle(color: teacher.isActive ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // toggle status
                  final svc = ref.read(teacherManagementServiceProvider);
                  if (teacher.isActive) {
                    svc.deactivateTeacher(teacher.id);
                  } else {
                    svc.reactivateTeacher(teacher.id);
                  }
                },
                icon: Icon(teacher.isActive ? Icons.block : Icons.check_circle_outline),
                label: Text(teacher.isActive ? 'Deactivate' : 'Reactivate'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => AddEditTeacherSheet(teacher: teacher),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                label: const Text('Edit', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(TeacherModel teacher) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(title: 'Contact Information', children: [
          _InfoRow(Icons.email_outlined, 'Email', teacher.email),
          _InfoRow(Icons.phone_outlined, 'Phone', teacher.phone ?? 'Not set'),
        ]),
        const SizedBox(height: 16),
        _InfoCard(title: 'Professional Information', children: [
          _InfoRow(Icons.school_outlined, 'Qualification', teacher.qualification ?? 'Not set'),
          _InfoRow(Icons.work_outline, 'Experience', teacher.experienceDisplay),
          _InfoRow(Icons.calendar_today_outlined, 'Joined', teacher.joiningDate?.toString().split(' ')[0] ?? 'Not set'),
        ]),
        const SizedBox(height: 16),
        _InfoCard(title: 'Financial Information', children: [
          _InfoRow(Icons.payments_outlined, 'Salary', teacher.salaryDisplay),
        ]),
        const SizedBox(height: 16),
        _InfoCard(title: 'Address', children: [
          _InfoRow(Icons.location_on_outlined, 'Address', teacher.address ?? 'Not set'),
        ]),
      ],
    );
  }

  Widget _buildBatchesTab(BuildContext context, WidgetRef ref, TeacherModel teacher) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () async {
              final svc = ref.read(teacherManagementServiceProvider);
              final activeBatches = await svc.fetchActiveBatches();
              final unassignedBatches = activeBatches.where((b) => !teacher.assignedBatches.contains(b['name'])).toList();
              
              if (!context.mounted) return;
              
              if (unassignedBatches.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No unassigned active batches available.')));
                return;
              }

              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Assign to Batch'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: unassignedBatches.length,
                      itemBuilder: (ctx, i) {
                        final b = unassignedBatches[i];
                        return ListTile(
                          title: Text(b['name']),
                          trailing: const Icon(Icons.add_circle_outline, color: Color(0xFFF97316)),
                          onTap: () async {
                            Navigator.pop(ctx);
                            await svc.assignToBatch(teacherId: teacher.id, batchId: b['id'], batchName: b['name'], teacherName: teacher.name);
                          },
                        );
                      },
                    ),
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
                ),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Assign to New Batch', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D7377),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: teacher.assignedBatches.isEmpty
              ? const Center(child: Text('No batches assigned'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: teacher.assignedBatches.length,
                  itemBuilder: (context, index) {
                    final batchName = teacher.assignedBatches[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFFF97316), child: Icon(Icons.group, color: Colors.white)),
                        title: Text(batchName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Remove from Batch?'),
                                content: Text('Are you sure you want to remove ${teacher.name} from $batchName?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              final svc = ref.read(teacherManagementServiceProvider);
                              // We need batchId to remove, which we can fetch easily or just run a query by name.
                              // Since assignedBatches only has names, let's fetch active batches to get ID, or we can use Supabase to delete by teacher_id and batch_name.
                              // Actually, the service needs batchId. Let's do a quick lookup:
                              final activeBatches = await svc.fetchActiveBatches();
                              final target = activeBatches.firstWhere((b) => b['name'] == batchName, orElse: () => <String, dynamic>{});
                              if (target.isNotEmpty) {
                                await svc.removeFromBatch(teacherId: teacher.id, batchId: target['id']);
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab(TeacherModel teacher) {
    // A full schedule would query the lectures table across all assigned batches.
    // For this UI, we show a placeholder.
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aggregated Schedule coming soon.', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D7377))),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
