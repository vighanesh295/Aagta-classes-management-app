import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/teacher_model.dart';
import '../../../providers/teacher_management_provider.dart';

class AddEditTeacherSheet extends ConsumerStatefulWidget {
  final TeacherModel? teacher;

  const AddEditTeacherSheet({super.key, this.teacher});

  @override
  ConsumerState<AddEditTeacherSheet> createState() => _AddEditTeacherSheetState();
}

class _AddEditTeacherSheetState extends ConsumerState<AddEditTeacherSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _subjectController = TextEditingController();
  final _qualificationController = TextEditingController();
  
  final _salaryController = TextEditingController();

  int _experienceYears = 0;
  DateTime? _joiningDate = DateTime.now();
  bool _isActive = true;
  
  File? _selectedImage;
  bool _isLoading = false;

  List<Map<String, dynamic>> _activeBatches = [];
  final Set<String> _selectedBatchIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    if (widget.teacher != null) {
      final t = widget.teacher!;
      _nameController.text = t.name;
      _emailController.text = t.email;
      _phoneController.text = t.phone ?? '';
      _addressController.text = t.address ?? '';
      _subjectController.text = t.subject ?? '';
      _qualificationController.text = t.qualification ?? '';
      _salaryController.text = t.salary > 0 ? t.salary.toStringAsFixed(0) : '';
      _experienceYears = t.experienceYears;
      _joiningDate = t.joiningDate ?? DateTime.now();
      _isActive = t.isActive;
    }
    _loadActiveBatches();
  }

  Future<void> _loadActiveBatches() async {
    try {
      final batches = await ref.read(teacherManagementServiceProvider).fetchActiveBatches();
      if (mounted) {
        setState(() {
          _activeBatches = batches;
          // In edit mode, we could pre-select batches if we fetched them by ID,
          // but our model currently only has batch_names. For a complete implementation,
          // teacher model could also store batch_ids, or we do a lookup.
          // For now, new assignments will be handled via the batches tab in detail screen.
          // This modal's assign feature is best for new teachers.
        });
      }
    } catch (e) {
      // Handle error quietly
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _subjectController.dispose();
    _qualificationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final svc = ref.read(teacherManagementServiceProvider);
      
      String? photoUrl = widget.teacher?.photoUrl;
      final double salary = double.tryParse(_salaryController.text) ?? 0;

      if (widget.teacher == null) {
        // Create new teacher
        await svc.inviteTeacher(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          subject: _subjectController.text.trim(),
          qualification: _qualificationController.text.trim(),
          experienceYears: _experienceYears,
          address: _addressController.text.trim(),
          joiningDate: _joiningDate,
          salary: salary,
        );
        
        // Note: Edge func returns teacher_id but we don't capture it directly yet to do batch assignments here.
        // We'll instruct users to assign batches from the Detail Screen for now.

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Teacher invited successfully.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        // Edit existing teacher
        if (_selectedImage != null) {
          photoUrl = await svc.uploadTeacherPhoto(widget.teacher!.id, _selectedImage!);
        }

        final updated = widget.teacher!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          subject: _subjectController.text.trim(),
          qualification: _qualificationController.text.trim(),
          experienceYears: _experienceYears,
          address: _addressController.text.trim(),
          joiningDate: _joiningDate,
          salary: salary,
          isActive: _isActive,
          photoUrl: photoUrl,
        );
        
        await svc.updateTeacher(updated);
        
        // Handle batch assignments that were checked
        for (final bId in _selectedBatchIds) {
          final bName = _activeBatches.firstWhere((b) => b['id'] == bId)['name'];
          await svc.assignToBatch(teacherId: widget.teacher!.id, batchId: bId, batchName: bName, teacherName: updated.name);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Teacher updated successfully.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(widget.teacher == null ? 'Add Teacher' : 'Edit Teacher', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFF97316),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFFF97316),
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Personal'),
                  Tab(text: 'Professional'),
                  Tab(text: 'Other'),
                ],
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPersonalInfoTab(),
                    _buildProfessionalInfoTab(),
                    _buildOtherDetailsTab(),
                  ],
                ),
              ),
              // Bottom Action Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.teacher == null ? 'Send Invite & Save' : 'Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: _selectedImage != null 
                  ? FileImage(_selectedImage!) as ImageProvider
                  : (widget.teacher?.photoUrl != null ? CachedNetworkImageProvider(widget.teacher!.photoUrl!) : null),
              child: _selectedImage == null && widget.teacher?.photoUrl == null
                  ? const Icon(Icons.camera_alt, color: Colors.grey, size: 30)
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            enabled: widget.teacher == null,
            decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Full Address', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Primary Subject', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _qualificationController,
            decoration: const InputDecoration(labelText: 'Qualification (e.g. M.Sc, B.Ed)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Experience Years:', style: TextStyle(fontSize: 16)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  if (_experienceYears > 0) setState(() => _experienceYears--);
                },
              ),
              Text('$_experienceYears', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => _experienceYears++),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Joining Date'),
            subtitle: Text(_joiningDate == null ? 'Not set' : _joiningDate!.toString().split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _joiningDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (d != null) setState(() => _joiningDate = d);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOtherDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _salaryController,
            decoration: const InputDecoration(labelText: 'Salary (₹ per month)', prefixText: '₹ ', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          if (widget.teacher != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active Status'),
              subtitle: Text(_isActive ? 'Teacher is active' : 'Teacher is deactivated'),
              value: _isActive,
              activeThumbColor: const Color(0xFFF97316),
              onChanged: (val) => setState(() => _isActive = val),
            ),
          const SizedBox(height: 16),
          const Text('Assign Batches (Optional):', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_activeBatches.isEmpty)
            const Text('No active batches available.', style: TextStyle(color: Colors.grey)),
          ..._activeBatches.map((b) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(b['name']),
            activeColor: const Color(0xFFF97316),
            value: _selectedBatchIds.contains(b['id']),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedBatchIds.add(b['id']);
                } else {
                  _selectedBatchIds.remove(b['id']);
                }
              });
            },
          )),
        ],
      ),
    );
  }
}
