import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../providers/student_management_provider.dart';
import '../widgets/add_edit_student_sheet.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  final String studentId;
  const StudentDetailScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> with SingleTickerProviderStateMixin {
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
    final studentsAsync = ref.watch(filteredStudentsProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Student Details', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFF97316))),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (students) {
          final studentList = students.where((s) => s.id == widget.studentId).toList();
          if (studentList.isEmpty) return const Center(child: Text('Student not found'));
          final student = studentList.first;

          return Column(
            children: [
              // Header profile card
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFFF97316).withValues(alpha: 0.1),
                      backgroundImage: student.photoUrl != null && student.photoUrl.toString().isNotEmpty
                          ? CachedNetworkImageProvider(student.photoUrl!)
                          : null,
                      child: student.photoUrl == null || student.photoUrl.toString().isEmpty
                          ? Text(student.initials, style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 24))
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF1E293B))),
                          const SizedBox(height: 4),
                          Text(student.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: student.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: student.isActive ? Colors.green.shade200 : Colors.red.shade200),
                                ),
                                child: Text(student.isActive ? 'Active' : 'Inactive', 
                                    style: TextStyle(color: student.isActive ? Colors.green.shade700 : Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              if (student.batch != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Text('Batch: ${student.batch}', 
                                      style: TextStyle(color: Colors.blue.shade700, fontSize: 11, fontWeight: FontWeight.w600)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFF97316)),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (ctx) => AddEditStudentSheet(student: student),
                        );
                      },
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
                    Tab(text: 'Attendance'),
                    Tab(text: 'Payments'),
                  ],
                ),
              ),

              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(student),
                    const Center(child: Text('Attendance Records (Stub)', style: TextStyle(color: Colors.grey))),
                    const Center(child: Text('Payment Records (Stub)', style: TextStyle(color: Colors.grey))),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(dynamic student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Academic Information',
            Icons.school,
            [
              _buildInfoRow('Roll Number', student.rollNumber ?? 'Not set'),
              _buildInfoRow('Batch', student.batch ?? 'Not set'),
              _buildInfoRow('Joined At', student.joinedAt?.toString().split(' ')[0] ?? 'Not set'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Personal Information',
            Icons.person,
            [
              _buildInfoRow('Phone', student.phone ?? 'Not set'),
              _buildInfoRow('Date of Birth', student.dateOfBirth?.toString().split(' ')[0] ?? 'Not set'),
              _buildInfoRow('Gender', student.gender == null ? 'Not set' : student.gender![0].toUpperCase() + student.gender!.substring(1)),
              _buildInfoRow('Age', student.dateOfBirth == null ? 'Not set' : student.ageDisplay),
              _buildInfoRow('Address', student.address ?? 'Not set'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Parent / Guardian',
            Icons.family_restroom,
            [
              _buildInfoRow('Parent Name', student.parentName ?? 'Not set'),
              _buildInfoRow('Parent Phone', student.parentPhone ?? 'Not set'),
              _buildInfoRow('Parent Email', student.parentEmail ?? 'Not set'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFF97316), size: 20),
                const SizedBox(width: 8),
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: const Color(0xFF1E293B))),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }
}
