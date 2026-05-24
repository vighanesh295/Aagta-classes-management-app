// lib/features/admin/screens/fee_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/fee_model.dart';
import '../../../providers/fee_provider.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/stat_card.dart';

class FeeManagementScreen extends ConsumerStatefulWidget {
  const FeeManagementScreen({super.key});
  @override
  ConsumerState<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends ConsumerState<FeeManagementScreen> {
  String _filter = 'all'; // all, paid, pending

  @override
  Widget build(BuildContext context) {
    final feesAsync = ref.watch(allFeesProvider);

    return Scaffold(
      appBar: const GoldenAppBar(title: 'Fee Management'),
      body: feesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (fees) {
          final collected = fees.fold(0.0, (sum, f) => sum + f.paidAmount);
          final pending   = fees.fold(0.0, (sum, f) => sum + f.remaining);

          final filtered = _filter == 'all' ? fees
              : _filter == 'paid'
                  ? fees.where((f) => f.remaining <= 0).toList()
                  : fees.where((f) => f.remaining > 0).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                Expanded(child: StatCard(
                  label: 'Collected', value: 'â‚¹${(collected / 1000).toStringAsFixed(1)}K',
                  icon: Icons.check_circle_rounded,
                  iconColor: Colors.green, iconBg: Colors.green.withValues(alpha: 0.1),
                  valueColor: Colors.green,
                )),
                const SizedBox(width: 10),
                Expanded(child: StatCard(
                  label: 'Pending', value: 'â‚¹${(pending / 1000).toStringAsFixed(1)}K',
                  icon: Icons.pending_rounded,
                  iconColor: Theme.of(context).colorScheme.error, iconBg: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  valueColor: Theme.of(context).colorScheme.error,
                )),
              ]).animate().fadeIn(),
              const SizedBox(height: 16),

              // Filter chips
              Row(children: [
                _buildChip('All', 'all'),
                const SizedBox(width: 8),
                _buildChip('Pending', 'pending'),
                const SizedBox(width: 8),
                _buildChip('Paid', 'paid'),
              ]).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 16),

              ...filtered.asMap().entries.map((e) {
                final fee = e.value;
                return _FeeTile(fee: fee).animate().fadeIn(delay: (e.key * 40).ms);
              }),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, String value) => GestureDetector(
    onTap: () => setState(() => _filter = value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _filter == value ? Theme.of(context).colorScheme.secondary : Theme.of(context).dividerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(
        color: _filter == value ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8) ?? Colors.grey,
        fontWeight: FontWeight.w600, fontSize: 13,
      )),
    ),
  );
}

class _FeeTile extends StatelessWidget {
  final FeeModel fee;
  const _FeeTile({required this.fee});

  @override
  Widget build(BuildContext context) => PremiumCard(
    margin: const EdgeInsets.only(bottom: 8),
    showGoldBorder: fee.remaining > 0,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          child: Text(fee.studentName.isNotEmpty ? fee.studentName[0].toUpperCase() : 'S',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(fee.studentName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: fee.remaining <= 0 ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(fee.remaining <= 0 ? 'PAID' : 'PENDING',
              style: TextStyle(
                  color: fee.remaining <= 0 ? Colors.green : Colors.orange,
                  fontSize: 9, fontWeight: FontWeight.w800)),
        ),
      ]),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _feeVal(context, 'Total',     'â‚¹${fee.totalFees.toStringAsFixed(0)}',  Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black),
        _feeVal(context, 'Paid',      'â‚¹${fee.paidAmount.toStringAsFixed(0)}', Colors.green),
        _feeVal(context, 'Remaining', 'â‚¹${fee.remaining.toStringAsFixed(0)}',  fee.remaining > 0 ? Theme.of(context).colorScheme.error : Colors.green),
      ]),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: (fee.paidPercent / 100).clamp(0.0, 1.0),
        backgroundColor: Theme.of(context).dividerColor,
        valueColor: AlwaysStoppedAnimation(
            fee.remaining <= 0 ? Colors.green : Theme.of(context).colorScheme.secondary),
        minHeight: 4,
        borderRadius: BorderRadius.circular(2),
      ),
    ]),
  );

  Widget _feeVal(BuildContext context, String l, String v, Color c) => Column(children: [
    Text(l, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 10)),
    Text(v, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 13)),
  ]);
}
