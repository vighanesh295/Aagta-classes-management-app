import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/services/report_export_service.dart';
import '../../../models/analytics_model.dart';
import '../../../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  final _exportService = ReportExportService();
  bool _isExporting = false;

  void _refresh() {
    ref.invalidate(overviewAnalyticsProvider);
    ref.invalidate(feeAnalyticsProvider);
    ref.invalidate(monthlyFeeProvider);
    ref.invalidate(studentsPerBatchProvider);
    ref.invalidate(attendanceAnalyticsProvider);
    ref.invalidate(materialAnalyticsProvider);
  }

  Future<void> _exportReport({required bool isPdf}) async {
    Navigator.pop(context); // Close bottom sheet
    setState(() => _isExporting = true);
    
    try {
      final overview = await ref.read(overviewAnalyticsProvider.future);
      final fees = await ref.read(feeAnalyticsProvider.future);
      final monthlyFees = await ref.read(monthlyFeeProvider.future);
      final attendance = await ref.read(attendanceAnalyticsProvider.future);
      final materials = await ref.read(materialAnalyticsProvider.future);
      final batchCounts = await ref.read(studentsPerBatchProvider.future);

      final file = isPdf 
          ? await _exportService.exportAnalyticsPdf(
              overview: overview, fees: fees, monthlyFees: monthlyFees, 
              attendance: attendance, materials: materials, batchCounts: batchCounts)
          : await _exportService.exportAnalyticsExcel(
              overview: overview, fees: fees, monthlyFees: monthlyFees, 
              attendance: attendance, materials: materials, batchCounts: batchCounts);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Report saved successfully', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF22C55E)),
        );
      }
      
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Export Failed'),
            content: Text(e.toString()),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Export Report', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
                title: Text('Export as PDF', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onTap: () => _exportReport(isPdf: true),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Color(0xFF22C55E)),
                title: Text('Export as Excel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onTap: () => _exportReport(isPdf: false),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Reports & Analytics', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: _isExporting ? null : _showExportOptions,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader('Overview Summary'),
                const SizedBox(height: 12),
                _buildOverviewSection(),

                const SizedBox(height: 24),

                _buildSectionHeader('Fee Analytics'),
                const SizedBox(height: 12),
                _buildFeeSection(),

                const SizedBox(height: 24),
                
                _buildSectionHeader('Students per Batch'),
                const SizedBox(height: 12),
                _buildStudentsPerBatchSection(),
                
                const SizedBox(height: 24),
                
                _buildSectionHeader('Attendance by Batch'),
                const SizedBox(height: 12),
                _buildAttendanceSection(),
                
                const SizedBox(height: 24),
                
                _buildSectionHeader('Study Materials Usage'),
                const SizedBox(height: 12),
                _buildMaterialsSection(),
              ],
            ),
          ),
          if (_isExporting)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFF97316)),
                        SizedBox(height: 16),
                        Text('Generating report...', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.inter(color: const Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildOverviewSection() {
    final asyncData = ref.watch(overviewAnalyticsProvider);
    return asyncData.when(
      loading: () => _buildShimmerGrid(4),
      error: (e, _) => _buildErrorCard(e.toString()),
      data: (data) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _OverviewCard(icon: '👨‍🎓', number: data.totalStudents, label: 'Students'),
            _OverviewCard(icon: '👨‍🏫', number: data.totalTeachers, label: 'Teachers'),
            _OverviewCard(icon: '📚', number: data.totalBatches, label: 'Batches'),
            _OverviewCard(icon: '📄', number: data.totalMaterials, label: 'Materials'),
          ],
        );
      },
    );
  }

  Widget _buildFeeSection() {
    final feeAsync = ref.watch(feeAnalyticsProvider);
    final monthlyAsync = ref.watch(monthlyFeeProvider);

    return feeAsync.when(
      loading: () => _buildShimmerBox(300),
      error: (e, _) => _buildErrorCard(e.toString()),
      data: (feeData) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FeeStatItem(label: 'Assigned', amount: feeData.totalFeeAssigned),
                  _FeeStatItem(label: 'Collected', amount: feeData.totalCollected, isGreen: true),
                  _FeeStatItem(label: 'Pending', amount: feeData.totalPending, isRed: true),
                ],
              ),
              const SizedBox(height: 20),
              Text('Collection Rate: ${feeData.collectionPercentage.toStringAsFixed(1)}%',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              LinearPercentIndicator(
                lineHeight: 12,
                percent: feeData.totalFeeAssigned > 0 ? (feeData.totalCollected / feeData.totalFeeAssigned).clamp(0.0, 1.0) : 0,
                backgroundColor: Colors.grey.shade200,
                progressColor: const Color(0xFF22C55E),
                barRadius: const Radius.circular(6),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              if (feeData.totalStudentsWithFees > 0) ...[
                SizedBox(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        if (feeData.paidCount > 0)
                          PieChartSectionData(color: const Color(0xFF22C55E), value: feeData.paidCount.toDouble(), title: '${feeData.paidCount}', radius: 30, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        if (feeData.partialCount > 0)
                          PieChartSectionData(color: const Color(0xFFF97316), value: feeData.partialCount.toDouble(), title: '${feeData.partialCount}', radius: 30, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        if (feeData.unpaidCount > 0)
                          PieChartSectionData(color: const Color(0xFFEF4444), value: feeData.unpaidCount.toDouble(), title: '${feeData.unpaidCount}', radius: 30, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(const Color(0xFF22C55E), 'Paid'),
                    const SizedBox(width: 12),
                    _buildLegendItem(const Color(0xFFF97316), 'Partial'),
                    const SizedBox(width: 12),
                    _buildLegendItem(const Color(0xFFEF4444), 'Unpaid'),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),
              Text('Monthly Collections (Last 6)', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF1E293B))),
              const SizedBox(height: 16),
              monthlyAsync.when(
                loading: () => _buildShimmerBox(180),
                error: (e, _) => _buildErrorCard('Failed to load monthly data'),
                data: (monthlyData) {
                  if (monthlyData.isEmpty) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: Text('No monthly data available', style: TextStyle(color: Colors.grey))),
                    );
                  }
                  
                  double maxY = 0;
                  for (var m in monthlyData) {
                    if (m.collected > maxY) maxY = m.collected;
                  }
                  if (maxY == 0) maxY = 1000;

                  return SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY * 1.2,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < 0 || value.toInt() >= monthlyData.length) return const SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    monthlyData[value.toInt()].month.split(' ')[0], 
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                );
                              },
                              reservedSize: 28,
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: monthlyData.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.collected,
                                color: const Color(0xFFF97316),
                                width: 14,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              )
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentsPerBatchSection() {
    final asyncData = ref.watch(studentsPerBatchProvider);
    return asyncData.when(
      loading: () => _buildShimmerBox(250),
      error: (e, _) => _buildErrorCard(e.toString()),
      data: (data) {
        if (data.isEmpty) {
          return const Center(child: Text('No batches data available', style: TextStyle(color: Colors.grey)));
        }
        
        double maxY = 0;
        for (var d in data) {
          if (d.studentCount > maxY) maxY = d.studentCount.toDouble();
        }
        if (maxY == 0) maxY = 10;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY * 1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem('${data[groupIndex].batch}\n${rod.toY.toInt()} Students', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                  }
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < 0 || value.toInt() >= data.length) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          data[value.toInt()].batch,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: data.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.studentCount.toDouble(),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFFB923C)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    )
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceSection() {
    final asyncData = ref.watch(attendanceAnalyticsProvider);
    return asyncData.when(
      loading: () => _buildShimmerBox(150),
      error: (e, _) => _buildErrorCard(e.toString()),
      data: (data) {
        if (data.isEmpty) {
          return const Center(child: Text('No attendance data available', style: TextStyle(color: Colors.grey)));
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final a = data[index];
            Color rateColor = const Color(0xFF22C55E);
            if (a.attendancePercentage < 75 && a.attendancePercentage >= 50) rateColor = const Color(0xFFF97316);
            if (a.attendancePercentage < 50) rateColor = const Color(0xFFEF4444);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  CircularPercentIndicator(
                    radius: 32,
                    lineWidth: 6,
                    percent: (a.attendancePercentage / 100).clamp(0.0, 1.0),
                    center: Text('${a.attendancePercentage.toStringAsFixed(0)}%', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: rateColor)),
                    progressColor: rateColor,
                    backgroundColor: Colors.grey.shade200,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.batch, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF1E293B))),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _AttendanceStat(label: 'P: ', value: '${a.presentCount}', color: const Color(0xFF22C55E)),
                            const SizedBox(width: 12),
                            _AttendanceStat(label: 'A: ', value: '${a.absentCount}', color: const Color(0xFFEF4444)),
                            const SizedBox(width: 12),
                            _AttendanceStat(label: 'L: ', value: '${a.lateCount}', color: const Color(0xFFF97316)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMaterialsSection() {
    final asyncData = ref.watch(materialAnalyticsProvider);
    return asyncData.when(
      loading: () => _buildShimmerBox(150),
      error: (e, _) => _buildErrorCard(e.toString()),
      data: (data) {
        if (data.isEmpty) {
          return const Center(child: Text('No material data available', style: TextStyle(color: Colors.grey)));
        }
        
        int maxDownloads = 0;
        for (var m in data) {
          if (m.totalDownloads > maxDownloads) maxDownloads = m.totalDownloads;
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final m = data[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m.batch, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF1E293B))),
                      Text('${m.totalMaterials} files', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.download, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text('${m.totalDownloads} total downloads', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: const Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 6,
                    percent: maxDownloads > 0 ? (m.totalDownloads / maxDownloads).clamp(0.0, 1.0) : 0,
                    backgroundColor: Colors.grey.shade200,
                    progressColor: const Color(0xFF3B82F6),
                    barRadius: const Radius.circular(3),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569), fontWeight: FontWeight.w600)),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFF1F5F9)),
      boxShadow: [
        BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    );
  }

  Widget _buildShimmerGrid(int count) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: List.generate(count, (index) => _buildShimmerBox(100)),
    );
  }

  Widget _buildShimmerBox(double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: Container(
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
          const SizedBox(width: 12),
          Expanded(child: Text(error, style: const TextStyle(color: Color(0xFFEF4444)))),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String icon;
  final int number;
  final String label;

  const _OverviewCard({required this.icon, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const Spacer(),
              Text('$number', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFFF97316))),
            ],
          ),
          const Spacer(),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FeeStatItem extends StatelessWidget {
  final String label;
  final double amount;
  final bool isGreen;
  final bool isRed;

  const _FeeStatItem({required this.label, required this.amount, this.isGreen = false, this.isRed = false});

  @override
  Widget build(BuildContext context) {
    Color color = const Color(0xFF0F172A);
    if (isGreen) color = const Color(0xFF22C55E);
    if (isRed) color = const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('₹${amount.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

class _AttendanceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  
  const _AttendanceStat({required this.label, required this.value, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
        Text(value, style: GoogleFonts.inter(fontSize: 13, color: color, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
