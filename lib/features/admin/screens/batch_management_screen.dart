// lib/features/admin/screens/batch_management_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase_service.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/golden_button.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/premium_card.dart';

final _batchesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseService.instance.batches
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
          .toList());
});

class BatchManagementScreen extends ConsumerStatefulWidget {
  const BatchManagementScreen({super.key});
  @override
  ConsumerState<BatchManagementScreen> createState() => _BatchManagementScreenState();
}

class _BatchManagementScreenState extends ConsumerState<BatchManagementScreen> {
  bool _showForm = false;
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _subjectCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() { _nameCtrl.dispose(); _subjectCtrl.dispose(); super.dispose(); }

  Future<void> _saveBatch() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await FirebaseService.instance.batches.add({
        'name': _nameCtrl.text.trim(),
        'subject': _subjectCtrl.text.trim(),
        'createdAt': Timestamp.now(),
        'studentCount': 0,
      });
      setState(() { _showForm = false; _saving = false; });
      _nameCtrl.clear(); _subjectCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch created!'), backgroundColor: Colors.green),
      );
      }
    } catch (e) { setState(() => _saving = false); }
  }

  Future<void> _deleteBatch(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Batch'),
        content: const Text('This will delete the batch permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (ok == true) await FirebaseService.instance.batches.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(_batchesProvider);
    return Scaffold(
      appBar: const GoldenAppBar(title: 'Batch Management'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showForm = !_showForm),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        child: Icon(_showForm ? Icons.close_rounded : Icons.add_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_showForm) ...[
            PremiumCard(
              showGoldBorder: true,
              child: Form(
                key: _formKey,
                child: Column(children: [
                  Text('Create Batch', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl,
                    validator: Validators.required,
                    decoration: const InputDecoration(labelText: 'Batch Name *', prefixIcon: Icon(Icons.groups_rounded)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _subjectCtrl,
                    decoration: const InputDecoration(labelText: 'Subject/Course', prefixIcon: Icon(Icons.book_outlined)),
                  ),
                  const SizedBox(height: 16),
                  GoldenButton(
                    label: 'Create Batch',
                    isLoading: _saving,
                    onPressed: _saving ? null : _saveBatch,
                    icon: Icons.add_rounded,
                  ),
                ]),
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 16),
          ],
          batchesAsync.when(
            loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
            error: (e, _) => Text('Error: $e'),
            data: (batches) {
              if (batches.isEmpty) {
                return Center(
                child: Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('No batches yet. Create one!', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
                )),
              );
              }
              return Column(
                children: batches.asMap().entries.map((e) {
                  final b = e.value;
                  return PremiumCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    showGoldBorder: true,
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.groups_rounded, color: Theme.of(context).colorScheme.secondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b['name'] ?? '', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        if ((b['subject'] ?? '').isNotEmpty)
                          Text(b['subject'], style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 12)),
                        Text('${b['studentCount'] ?? 0} students', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
                      ])),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error, size: 20),
                        onPressed: () => _deleteBatch(b['id']),
                      ),
                    ]),
                  ).animate().fadeIn(delay: (e.key * 40).ms);
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
