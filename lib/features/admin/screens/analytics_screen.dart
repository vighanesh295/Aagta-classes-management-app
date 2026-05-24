// lib/features/admin/screens/analytics_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/fee_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/stat_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync    = ref.watch(adminStatsProvider);
    final studentsAsync = ref.watch(allStudentsProvider);

    return Scaffold(
      appBar: const GoldenAppBar(title: 'Analytics'),
      body: statsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top stats
            Row(children: [
              Expanded(child: StatCard(
                label: 'Students', value: '${stats.totalStudents}',
                icon: Icons.school_rounded, iconColor: Colors.blue, iconBg: Colors.blue.withValues(alpha: 0.1),
              )),
              const SizedBox(width: 10),
              Expanded(child: StatCard(
                label: 'Teachers', value: '${stats.totalTeachers}',
                icon: Icons.person_rounded, iconColor: Colors.green, iconBg: Colors.green.withValues(alpha: 0.1),
              )),
            ]).animate().fadeIn(),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: StatCard(
                label: 'Fees Collected',
                value: 'â‚¹${(stats.totalFeesCollected / 1000).toStringAsFixed(1)}K',
                icon: Icons.check_circle_rounded,
                iconColor: Colors.green, iconBg: Colors.green.withValues(alpha: 0.1),
                valueColor: Colors.green,
              )),
              const SizedBox(width: 10),
              Expanded(child: StatCard(
                label: 'Pending Fees',
                value: 'â‚¹${(stats.totalPendingFees / 1000).toStringAsFixed(1)}K',
                icon: Icons.pending_rounded,
                iconColor: Theme.of(context).colorScheme.error, iconBg: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                valueColor: Theme.of(context).colorScheme.error,
              )),
            ]).animate().fadeIn(delay: 50.ms),
            const SizedBox(height: 20),

            // Fee collection pie
            PremiumCard(
              showGoldBorder: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Fee Collection Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: stats.totalFeesCollected,
                          title: 'Paid',
                          color: Colors.green,
                          radius: 60,
                          titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        PieChartSectionData(
                          value: stats.totalPendingFees,
                          title: 'Pending',
                          color: Theme.of(context).colorScheme.error,
                          radius: 60,
                          titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _legend('Collected', Colors.green),
                  const SizedBox(width: 24),
                  _legend('Pending', Theme.of(context).colorScheme.error),
                ]),
              ]),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),

            // Attendance distribution
            studentsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (students) {
                if (students.isEmpty) return const SizedBox.shrink();
                final above75   = students.where((s) => s.attendancePercent >= 75).length;
                final between60 = students.where((s) => s.attendancePercent >= 60 && s.attendancePercent < 75).length;
                final below60   = students.where((s) => s.attendancePercent < 60).length;

                return PremiumCard(
                  showGoldBorder: true,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Attendance Distribution',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: students.length.toDouble(),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(
                              toY: above75.toDouble(), color: Colors.green, width: 40,
                              borderRadius: BorderRadius.circular(4),
                            )]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(
                              toY: between60.toDouble(), color: Colors.orange, width: 40,
                              borderRadius: BorderRadius.circular(4),
                            )]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(
                              toY: below60.toDouble(), color: Theme.of(context).colorScheme.error, width: 40,
                              borderRadius: BorderRadius.circular(4),
                            )]),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                const labels = ['â‰¥75%', '60-75%', '<60%'];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(labels[v.toInt()],
                                      style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
                                );
                              },
                            )),
                            leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ]),
                ).animate().fadeIn(delay: 150.ms);
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

Widget _legend(String label, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
  Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
  const SizedBox(width: 6),
  Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
]);
