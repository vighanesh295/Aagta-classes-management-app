import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/batch_model.dart';
import '../../../providers/batch_provider.dart';

class AddEditBatchSheet extends ConsumerStatefulWidget {
  final BatchModel? batch;

  const AddEditBatchSheet({super.key, this.batch});

  @override
  ConsumerState<AddEditBatchSheet> createState() => _AddEditBatchSheetState();
}

class _AddEditBatchSheetState extends ConsumerState<AddEditBatchSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxStudentsController = TextEditingController(text: '30');
  final _feeAmountController = TextEditingController(text: '0');
  
  String? _selectedTeacherId;
  String? _selectedTeacherName;
  DateTime? _startDate;
  DateTime? _endDate;
  BatchStatus _status = BatchStatus.active;
  
  final List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> _selectedDays = {};
  
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isLoading = false;
  List<Map<String, dynamic>> _teachers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    if (widget.batch != null) {
      final b = widget.batch!;
      _nameController.text = b.name;
      _subjectController.text = b.subject ?? '';
      _descriptionController.text = b.description ?? '';
      _maxStudentsController.text = b.maxStudents.toString();
      _feeAmountController.text = b.feeAmount.toString();
      _selectedTeacherId = b.teacherId;
      _selectedTeacherName = b.teacherName;
      _startDate = b.startDate;
      _endDate = b.endDate;
      _status = b.status;
      _selectedDays.addAll(b.scheduleDays);
      
      if (b.scheduleTime != null) {
        // e.g. "10:00 AM - 12:00 PM"
        final parts = b.scheduleTime!.split(' - ');
        if (parts.length == 2) {
          _startTime = _parseTime(parts[0]);
          _endTime = _parseTime(parts[1]);
        }
      }
    }
    
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    try {
      final teachers = await ref.read(batchServiceProvider).fetchTeachers();
      if (mounted) {
        setState(() {
          _teachers = teachers;
          // Verify if selected teacher still exists
          if (_selectedTeacherId != null && !teachers.any((t) => t['id'] == _selectedTeacherId)) {
            _selectedTeacherId = null;
            _selectedTeacherName = null;
          }
        });
      }
    } catch (e) {
      // ignore
    }
  }

  TimeOfDay? _parseTime(String timeString) {
    try {
      // Very basic parsing for "10:00 AM" format
      final parts = timeString.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      if (parts[1].toUpperCase() == 'PM' && hour != 12) hour += 12;
      if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _maxStudentsController.dispose();
    _feeAmountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? scheduleTimeString;
      if (_startTime != null && _endTime != null) {
        scheduleTimeString = '${_startTime!.format(context)} - ${_endTime!.format(context)}';
      }

      final batchData = BatchModel(
        id: widget.batch?.id ?? '',
        name: _nameController.text.trim(),
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        teacherId: _selectedTeacherId,
        teacherName: _selectedTeacherName,
        maxStudents: int.tryParse(_maxStudentsController.text) ?? 30,
        feeAmount: double.tryParse(_feeAmountController.text) ?? 0.0,
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
        scheduleDays: _selectedDays.toList()..sort((a, b) => _daysOfWeek.indexOf(a).compareTo(_daysOfWeek.indexOf(b))),
        scheduleTime: scheduleTimeString,
        createdAt: widget.batch?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final svc = ref.read(batchServiceProvider);
      if (widget.batch == null) {
        await svc.createBatch(batchData);
      } else {
        await svc.updateBatch(batchData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.batch == null ? 'Batch created successfully' : 'Batch updated successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
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
      height: MediaQuery.of(context).size.height * 0.85,
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
                    Text(widget.batch == null ? 'Add Batch' : 'Edit Batch', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  Tab(text: 'Batch Info'),
                  Tab(text: 'Schedule'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInfoTab(),
                    _buildScheduleTab(),
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
                      : Text(widget.batch == null ? 'Create Batch' : 'Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.batch != null) ...[
            SegmentedButton<BatchStatus>(
              segments: const [
                ButtonSegment(value: BatchStatus.active, label: Text('Active')),
                ButtonSegment(value: BatchStatus.inactive, label: Text('Inactive')),
                ButtonSegment(value: BatchStatus.completed, label: Text('Completed')),
              ],
              selected: {_status},
              onSelectionChanged: (val) => setState(() => _status = val.first),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Batch Name *', border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedTeacherId,
            decoration: const InputDecoration(labelText: 'Assign Teacher', border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem(value: null, child: Text('None')),
              ..._teachers.map((t) => DropdownMenuItem<String>(value: t['id'], child: Text(t['name']))).toList(),
            ],
            onChanged: (val) {
              setState(() {
                _selectedTeacherId = val;
                if (val != null) {
                  _selectedTeacherName = _teachers.firstWhere((t) => t['id'] == val)['name'];
                } else {
                  _selectedTeacherName = null;
                }
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _maxStudentsController,
                  decoration: const InputDecoration(labelText: 'Max Students', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _feeAmountController,
                  decoration: const InputDecoration(labelText: 'Fee Amount', prefixText: '₹ ', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start Date', style: TextStyle(fontSize: 12)),
                  subtitle: Text(_startDate == null ? 'Not set' : _startDate!.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today, size: 16),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (d != null) setState(() => _startDate = d);
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End Date', style: TextStyle(fontSize: 12)),
                  subtitle: Text(_endDate == null ? 'Not set' : _endDate!.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today, size: 16),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: _endDate ?? (_startDate ?? DateTime.now()), firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (d != null) setState(() => _endDate = d);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Days of week', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _daysOfWeek.map((day) {
              final isSelected = _selectedDays.contains(day);
              return FilterChip(
                label: Text(day),
                selected: isSelected,
                selectedColor: const Color(0xFFF97316),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFFF97316)),
                backgroundColor: const Color(0xFFFFF4EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFF97316)),
                ),
                onSelected: (val) {
                  setState(() {
                    if (val) _selectedDays.add(day);
                    else _selectedDays.remove(day);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Schedule Time', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: _startTime ?? const TimeOfDay(hour: 10, minute: 0));
                    if (t != null) setState(() => _startTime = t);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(_startTime?.format(context) ?? 'Select Time', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: _endTime ?? const TimeOfDay(hour: 12, minute: 0));
                    if (t != null) setState(() => _endTime = t);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('To', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(_endTime?.format(context) ?? 'Select Time', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
