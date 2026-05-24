// lib/features/student/screens/fee_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../models/fee_model.dart';
import '../../../providers/student_provider.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/stat_card.dart';

class FeeDetailsScreen extends ConsumerWidget {
  const FeeDetailsScreen({super.key});

  String _fmt(double v) =>
      v >= 1000 ? 'â‚¹${(v / 1000).toStringAsFixed(1)}K' : 'â‚¹${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feeAsync   = ref.watch(studentFeeProvider);
    final instsAsync = ref.watch(studentInstallmentsProvider);

    return Scaffold(
      appBar: const GoldenAppBar(title: 'Fee Details'),
      body: feeAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data: (fee) {
          if (fee == null) {
            return Center(
            child: Text('No fee record found.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)));
          }

          final insts = instsAsync.valueOrNull ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overview card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.35),
                    blurRadius: 16, offset: const Offset(0, 6),
                  )],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text('Fee Overview', style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Image.asset(AppAssets.logo, height: 24, fit: BoxFit.contain,
                        color: Colors.white.withValues(alpha: 0.85),
                        colorBlendMode: BlendMode.srcIn),
                  ]),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _FeeItem('Total Fees',    _fmt(fee.totalFees),  Colors.white),
                    _FeeItem('Paid',          _fmt(fee.paidAmount), const Color(0xFFB9F6CA)),
                    _FeeItem('Remaining',     _fmt(fee.remaining),  fee.remaining > 0 ? const Color(0xFFFFE0B2) : Colors.white),
                  ]),
                  const SizedBox(height: 16),
                  LinearPercentIndicator(
                    lineHeight: 8,
                    percent: (fee.paidPercent / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    progressColor: Colors.white,
                    barRadius: const Radius.circular(4),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  Text('${fee.paidPercent.toStringAsFixed(0)}% paid',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                ]),
              ).animate().fadeIn(),
              const SizedBox(height: 20),

              // Quick stats
              Row(children: [
                Expanded(child: StatCard(
                  label: 'Status', value: fee.overallStatus.label,
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: fee.remaining <= 0 ? Colors.green : Colors.orange,
                  iconBg:    fee.remaining <= 0 ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  valueColor: fee.remaining <= 0 ? Colors.green : Colors.orange,
                )),
                const SizedBox(width: 10),
                Expanded(child: StatCard(
                  label: 'Installments', value: '${insts.length}',
                  icon: Icons.receipt_long_rounded,
                  iconColor: Colors.blue, iconBg: Colors.blue.withValues(alpha: 0.1),
                )),
              ]).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 20),

              // Installments
              const SectionHeader(title: AppStrings.installments).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 12),
              ...insts.asMap().entries.map((e) => _InstallmentCard(
                inst: e.value, index: e.key,
              ).animate().fadeIn(delay: (200 + e.key * 50).ms)),

              if (insts.isEmpty)
                Center(
                  child: Center(child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('No installments found.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
                  )),
                ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _FeeItem extends StatelessWidget {
  final String label; final String value; final Color color;
  const _FeeItem(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
  ]);
}

class _InstallmentCard extends StatelessWidget {
  final InstallmentModel inst;
  final int index;
  const _InstallmentCard({required this.inst, required this.index});

  Color _statusColor(BuildContext context) {
    switch (inst.status) {
      case FeeStatus.paid:    return Colors.green;
      case FeeStatus.overdue: return Theme.of(context).colorScheme.error;
      case FeeStatus.pending: return inst.isDueSoon ? Colors.orange : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8) ?? Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) => PremiumCard(
    showGoldBorder: inst.isDueSoon,
    margin: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      // Number badge
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text('${index + 1}', style: TextStyle(
              color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w800, fontSize: 14)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Installment #${inst.installmentNo}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        Text(AppDateUtils.dueDateLabel(inst.dueDate),
            style: TextStyle(color: _statusColor(context), fontSize: 11, fontWeight: FontWeight.w600)),
        if (inst.paidDate != null)
          Text('Paid on ${AppDateUtils.formatDate(inst.paidDate!)}',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 11)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('â‚¹${inst.amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w800)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _statusColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(inst.status.label.toUpperCase(),
              style: TextStyle(color: _statusColor(context), fontSize: 9, fontWeight: FontWeight.w700)),
        ),
      ]),
    ]),
  );
}
