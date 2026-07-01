import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/student_model.dart';
import '../../../providers/student_management_provider.dart';
import '../../../providers/batch_provider.dart';

class AddEditStudentSheet extends ConsumerStatefulWidget {
  final StudentModel? student;

  const AddEditStudentSheet({super.key, this.student});

  @override
  ConsumerState<AddEditStudentSheet> createState() => _AddEditStudentSheetState();
}

class _AddEditStudentSheetState extends ConsumerState<AddEditStudentSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rollController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedBatch;
  DateTime? _dateOfBirth;
  String? _gender;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.student != null) {
      final s = widget.student!;
      _nameController.text = s.name;
      _emailController.text = s.email;
      _phoneController.text = s.phone ?? '';
      _rollController.text = s.rollNumber ?? '';
      _parentNameController.text = s.parentName ?? '';
      _parentPhoneController.text = s.parentPhone ?? '';
      _parentEmailController.text = s.parentEmail ?? '';
      _addressController.text = s.address ?? '';
      _selectedBatch = s.batch;
      _dateOfBirth = s.dateOfBirth;
      _gender = s.gender;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rollController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _parentEmailController.dispose();
    _addressController.dispose();
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
      // Switch to the first tab if basic info is invalid (simple heuristic)
      if (_nameController.text.isEmpty || _emailController.text.isEmpty || _selectedBatch == null) {
        _tabController.animateTo(0);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final svc = ref.read(studentManagementServiceProvider);
      
      String? photoUrl = widget.student?.photoUrl;

      if (widget.student == null) {
        // Create new student
        await svc.inviteStudent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          batch: _selectedBatch!,
          phone: _phoneController.text.trim(),
          rollNumber: _rollController.text.trim(),
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          address: _addressController.text.trim(),
          parentName: _parentNameController.text.trim(),
          parentPhone: _parentPhoneController.text.trim(),
          parentEmail: _parentEmailController.text.trim(),
        );
        
        // Note: we can't easily upload the photo here without knowing the user ID created by the edge function.
        // In a real app, the edge function would return the user_id, which we could use to upload the photo.
        // For simplicity, photo upload is skipped for brand new invites unless we modify the edge func to return id and parse it.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student invited successfully. They will receive an email to set their password.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        // Edit existing student
        if (_selectedImage != null) {
          photoUrl = await svc.uploadStudentPhoto(widget.student!.id, _selectedImage!);
        }

        final updated = widget.student!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          batch: _selectedBatch,
          rollNumber: _rollController.text.trim(),
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          address: _addressController.text.trim(),
          parentName: _parentNameController.text.trim(),
          parentPhone: _parentPhoneController.text.trim(),
          parentEmail: _parentEmailController.text.trim(),
          photoUrl: photoUrl,
        );
        
        await svc.updateStudent(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student updated successfully.'), backgroundColor: Colors.green),
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
                    Text(widget.student == null ? 'Add Student' : 'Edit Student', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
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
                tabs: const [
                  Tab(text: 'Basic Info'),
                  Tab(text: 'Parent Info'),
                  Tab(text: 'Address'),
                ],
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBasicInfoTab(),
                    _buildParentInfoTab(),
                    _buildAddressTab(),
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
                      : Text(widget.student == null ? 'Send Invite & Save' : 'Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    final batchesAsync = ref.watch(activeBatchesProvider);
    
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
                  : (widget.student?.photoUrl != null ? CachedNetworkImageProvider(widget.student!.photoUrl!) : null),
              child: _selectedImage == null && widget.student?.photoUrl == null
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
            enabled: widget.student == null,
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
          DropdownButtonFormField<String>(
            value: _selectedBatch,
            decoration: const InputDecoration(labelText: 'Batch *', border: OutlineInputBorder()),
            items: batchesAsync.when(
              data: (batches) => batches.map((b) => DropdownMenuItem(value: b.name, child: Text(b.name))).toList(),
              loading: () => [],
              error: (_, __) => [],
            ),
            onChanged: (val) {
              setState(() {
                _selectedBatch = val;
                if (widget.student == null && _rollController.text.isEmpty && val != null) {
                  // Suggest roll number prefix
                  _rollController.text = '${val.substring(0, 3).toUpperCase()}-';
                }
              });
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _rollController,
            decoration: const InputDecoration(labelText: 'Roll Number', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date of Birth'),
            subtitle: Text(_dateOfBirth == null ? 'Not set' : _dateOfBirth!.toString().split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _dateOfBirth ?? DateTime(2010), firstDate: DateTime(1990), lastDate: DateTime.now());
              if (d != null) setState(() => _dateOfBirth = d);
            },
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'male', label: Text('Male')),
              ButtonSegment(value: 'female', label: Text('Female')),
              ButtonSegment(value: 'other', label: Text('Other')),
            ],
            selected: _gender != null ? {_gender!} : <String>{},
            onSelectionChanged: (val) => setState(() => _gender = val.first),
            emptySelectionAllowed: true,
          ),
        ],
      ),
    );
  }

  Widget _buildParentInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: _parentNameController,
            decoration: const InputDecoration(labelText: 'Parent Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _parentPhoneController,
            decoration: const InputDecoration(labelText: 'Parent Phone', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _parentEmailController,
            decoration: const InputDecoration(labelText: 'Parent Email', border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        controller: _addressController,
        maxLines: 5,
        decoration: const InputDecoration(labelText: 'Full Address', border: OutlineInputBorder()),
      ),
    );
  }
}
