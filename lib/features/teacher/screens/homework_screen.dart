// lib/features/teacher/screens/homework_screen.dart
import '../../../core/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/golden_button.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/stat_card.dart';

final _homeworkProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return SupabaseService.instance.client
      .from('homework')
      .stream(primaryKey: ['id'])
      .eq('teacher_id', user.uid)
      .order('dueDate', ascending: false)
      .limit(30);
});

class HomeworkScreen extends ConsumerStatefulWidget {
  const HomeworkScreen({super.key});
  @override
  ConsumerState<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends ConsumerState<HomeworkScreen> {
  bool _showForm = false;
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;
      await SupabaseService.instance.client.from('homework').insert({
        'title':     _titleCtrl.text.trim(),
        'subject':   _subjectCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'teacher_id': user.uid,
        'dueDate':   _dueDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
      setState(() { _showForm = false; _saving = false; });
      _titleCtrl.clear(); _subjectCtrl.clear(); _descCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Homework posted!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(primary: Theme.of(context).colorScheme.secondary),
      ), child: child!),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final hwAsync = ref.watch(_homeworkProvider);

    return Scaffold(
      appBar: const GoldenAppBar(title: 'Homework'),
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
                  Text('Post Homework', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleCtrl,
                    validator: Validators.required,
                    decoration: const InputDecoration(labelText: 'Title *', prefixIcon: Icon(Icons.title_rounded)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _subjectCtrl,
                    validator: Validators.required,
                    decoration: const InputDecoration(labelText: 'Subject *', prefixIcon: Icon(Icons.book_outlined)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Instructions',
                      prefixIcon: Icon(Icons.description_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    child: PremiumCard(
                      showGoldBorder: true,
                      child: Row(children: [
                        Icon(Icons.calendar_today_rounded, color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Due Date', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 12)),
                          Text(AppDateUtils.formatDate(_dueDate), style: const TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GoldenButton(
                    label: 'Post Homework',
                    isLoading: _saving,
                    onPressed: _saving ? null : _save,
                    icon: Icons.send_rounded,
                  ),
                ]),
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 20),
          ],

          const SectionHeader(title: 'Posted Homework'),
          const SizedBox(height: 12),

          hwAsync.when(
            loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
            error: (e, _) => Text('Error: $e'),
            data: (hws) {
              if (hws.isEmpty) {
                return Center(
                child: Center(child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No homework posted yet.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
                )),
              );
              }
              return Column(
                children: hws.asMap().entries.map((e) {
                  final hw = e.value;
                  final due = DateTime.tryParse(hw['dueDate']?.toString() ?? '') ?? DateTime.now();
                  return PremiumCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.assignment_rounded, color: Theme.of(context).colorScheme.secondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(hw['title'] ?? '', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        Text(hw['subject'] ?? '', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 12)),
                        Text('Due: ${AppDateUtils.formatDate(due)}',
                            style: TextStyle(
                              color: due.isBefore(DateTime.now()) ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary,
                              fontSize: 11, fontWeight: FontWeight.w600,
                            )),
                      ])),
                    ]),
                  ).animate().fadeIn(delay: (e.key * 50).ms);
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
