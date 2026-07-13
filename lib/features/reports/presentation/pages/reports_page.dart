import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  int _selectedReportIndex = 0;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(l10n),
          const SizedBox(height: 16),
          _buildReportTypes(l10n),
          const SizedBox(height: 16),
          _buildDateRangeSelector(l10n),
          const SizedBox(height: 16),
          _buildChartPreview(l10n),
          const SizedBox(height: 16),
          _buildExportOptions(l10n),
          const SizedBox(height: 16),
          _buildDetailedReport(l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3B4F), Color(0xFF156082)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assessment, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reports,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.company,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypes(AppLocalizations l10n) {
    final reports = [
      {
        'icon': Icons.water_drop,
        'title': l10n.waterUsage,
        'desc': l10n.waterUsageDesc,
        'color': const Color(0xFF2196F3),
      },
      {
        'icon': Icons.settings_input_antenna,
        'title': l10n.controllerStatus,
        'desc': l10n.controllerStatusDesc,
        'color': const Color(0xFF4CAF50),
      },
      {
        'icon': Icons.warning_amber,
        'title': l10n.alarmHistory,
        'desc': l10n.alarmHistoryDesc,
        'color': const Color(0xFFF44336),
      },
      {
        'icon': Icons.schedule,
        'title': l10n.scheduleReport,
        'desc': l10n.scheduleReportDesc,
        'color': const Color(0xFFFF9800),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectReportType,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF156082),
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
          ),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final isSelected = _selectedReportIndex == index;
            final color = report['color'] as Color;

            return GestureDetector(
              onTap: () => setState(() => _selectedReportIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade100,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))]
                      : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(report['icon'] as IconData, color: color, size: 22),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      report['title'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : const Color(0xFF212121),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        report['desc'] as String,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                l10n.dateRange,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF156082),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateField(l10n.fromDate, _fromDate, (date) {
                  if (date != null) setState(() => _fromDate = date);
                }),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(l10n.toDate, _toDate, (date) {
                  if (date != null) setState(() => _toDate = date);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, ValueChanged<DateTime?> onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: Color(0xFF156082)),
              ),
              child: child!,
            );
          },
        );
        onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPreview(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                l10n.chartPreview,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF156082),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} ${l10n.cubicMeters}',
                        const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = [l10n.saturday, l10n.sunday, l10n.monday, l10n.tuesday, l10n.wednesday, l10n.thursday, l10n.friday];
                        final idx = value.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(days[idx], style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: [
                  _buildBarGroup(0, 65, const Color(0xFF156082)),
                  _buildBarGroup(1, 45, const Color(0xFF156082)),
                  _buildBarGroup(2, 80, const Color(0xFF156082)),
                  _buildBarGroup(3, 55, const Color(0xFF156082)),
                  _buildBarGroup(4, 70, const Color(0xFF156082)),
                  _buildBarGroup(5, 40, const Color(0xFF156082)),
                  _buildBarGroup(6, 90, const Color(0xFF156082)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF156082),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.weeklyUsage,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 28,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          color: color,
        ),
      ],
    );
  }

  Widget _buildExportOptions(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildExportButton(
            l10n.exportPDF,
            Icons.picture_as_pdf,
            Colors.red.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildExportButton(
            l10n.exportCSV,
            Icons.table_chart,
            Colors.green.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedReport(AppLocalizations l10n) {
    final controllers = AppConstants.controllers;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.controllerStatus,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF156082),
            ),
          ),
          const SizedBox(height: 12),
          ...controllers.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF156082).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.settings_input_antenna,
                        color: Color(0xFF156082),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${c['id']} - ${c['name']}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.controllerStatus,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.online,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
