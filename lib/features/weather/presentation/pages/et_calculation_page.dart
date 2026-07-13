import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/features/weather/presentation/providers/et_provider.dart';

class ETCalculationPage extends ConsumerWidget {
  const ETCalculationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(etProvider);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF156082),
        title: Text(
          localizations.etCalculationTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildControllerSelector(context, ref, state, localizations),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCurrentEToGauge(context, state, localizations),
                const SizedBox(height: 16),
                _buildPenmanMonteithSection(context, state, localizations),
                const SizedBox(height: 16),
                _buildAccumulationCards(context, state, localizations),
                const SizedBox(height: 16),
                _buildETTrendChart(context, ref, state, localizations),
                const SizedBox(height: 16),
                _buildETReportSection(context, state, localizations),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControllerSelector(
    BuildContext context,
    WidgetRef ref,
    ETState state,
    AppLocalizations localizations,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.device_hub, color: Color(0xFF156082), size: 20),
          const SizedBox(width: 8),
          Text(
            localizations.controller,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: state.selectedController,
                  items: AppConstants.controllers.map((c) {
                    return DropdownMenuItem(
                      value: c['id']!,
                      child: Text('${c['id']} - ${c['name']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(etProvider.notifier).setController(value);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentEToGauge(
    BuildContext context,
    ETState state,
    AppLocalizations localizations,
  ) {
    final etValue = double.tryParse(state.currentETo) ?? 0.0;
    final gaugePercent = (etValue / 15.0).clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF03A9F4), Color(0xFF156082)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              localizations.etCurrentETo,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: gaugePercent,
                    strokeWidth: 12,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.currentETo,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'mm/day',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.etBasedOnPenmanMonteith,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenmanMonteithSection(
    BuildContext context,
    ETState state,
    AppLocalizations localizations,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: Color(0xFF156082), size: 22),
                const SizedBox(width: 8),
                Text(
                  localizations.etPenmanMonteith,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildParameterCard(
                  localizations.temperature,
                  state.temperature,
                  '°C',
                  const Color(0xFFFF5722),
                  Icons.thermostat,
                ),
                _buildParameterCard(
                  localizations.humidity,
                  state.humidity,
                  '%',
                  const Color(0xFF2196F3),
                  Icons.water_drop,
                ),
                _buildParameterCard(
                  localizations.windSpeed,
                  state.windSpeed,
                  'km/h',
                  const Color(0xFF4CAF50),
                  Icons.air,
                ),
                _buildParameterCard(
                  localizations.solarRadiation,
                  state.solarRadiation,
                  'W/m²',
                  const Color(0xFFFF9800),
                  Icons.wb_sunny,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calculate, color: Color(0xFF156082), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '${localizations.etCalculatedETo}: ',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    '${state.calculatedETo} mm/day',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF156082),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterCard(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        unit,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccumulationCards(
    BuildContext context,
    ETState state,
    AppLocalizations localizations,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline, color: Color(0xFF156082), size: 22),
                const SizedBox(width: 8),
                Text(
                  localizations.etAccumulation,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAccumulationRow(localizations.dailyET, state.dailyET, 0.3, const Color(0xFF4CAF50)),
            const SizedBox(height: 12),
            _buildAccumulationRow(localizations.weeklyET, state.weeklyET, 0.55, const Color(0xFF2196F3)),
            const SizedBox(height: 12),
            _buildAccumulationRow(localizations.monthlyET, state.monthlyET, 0.75, const Color(0xFFFF9800)),
            const SizedBox(height: 12),
            _buildAccumulationRow(localizations.yearlyET, state.yearlyET, 0.9, const Color(0xFF9C27B0)),
          ],
        ),
      ),
    );
  }

  Widget _buildAccumulationRow(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              '$value mm',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildETTrendChart(
    BuildContext context,
    WidgetRef ref,
    ETState state,
    AppLocalizations localizations,
  ) {
    final ranges = [
      {'range': TimeRange.oneHour, 'label': '1H'},
      {'range': TimeRange.sixHours, 'label': '6H'},
      {'range': TimeRange.twentyFourHours, 'label': '24H'},
      {'range': TimeRange.sevenDays, 'label': '7D'},
      {'range': TimeRange.thirtyDays, 'label': '30D'},
    ];

    final spots = state.etTrendData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    double minX = 0;
    double maxX = spots.isNotEmpty ? spots.last.x : 1;
    double minY = 0;
    double maxY = 10;
    if (spots.isNotEmpty) {
      final values = spots.map((s) => s.y).toList();
      minY = values.reduce((a, b) => a < b ? a : b);
      maxY = values.reduce((a, b) => a > b ? a : b);
      final margin = (maxY - minY) * 0.15;
      minY = (minY - margin).clamp(0.0, double.infinity);
      maxY += margin;
      if (minX == maxX) maxX = minX + 1;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Color(0xFF156082), size: 22),
                const SizedBox(width: 8),
                Text(
                  localizations.etTrendChart,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: ranges.map((r) {
                final isSelected = state.selectedTimeRange == r['range'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(etProvider.notifier).setTimeRange(r['range'] as TimeRange);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF156082) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: spots.isEmpty
                  ? Center(
                      child: Text(
                        localizations.noData,
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: const Color(0xFFF0F0F0),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < state.etTrendData.length) {
                                  final time = state.etTrendData[index].timestamp;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: minX,
                        maxX: maxX,
                        minY: minY,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF03A9F4), Color(0xFF4FC3F7)],
                            ),
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF03A9F4).withOpacity(0.2),
                                  const Color(0xFF03A9F4).withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) {
                              return spots.map((spot) {
                                return LineTooltipItem(
                                  '${spot.y.toStringAsFixed(2)} mm',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildETReportSection(
    BuildContext context,
    ETState state,
    AppLocalizations localizations,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assessment, color: Color(0xFF156082), size: 22),
                const SizedBox(width: 8),
                Text(
                  localizations.etReport,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReportRow(
              localizations.etValidDays,
              state.validETDays,
              Icons.event_available,
              const Color(0xFF4CAF50),
            ),
            const Divider(height: 20),
            _buildReportRow(
              localizations.etAverage,
              '${state.etAverage} mm',
              Icons.analytics,
              const Color(0xFF2196F3),
            ),
            const Divider(height: 20),
            _buildReportRow(
              localizations.etLast7Days,
              '${state.etLast7Days} mm',
              Icons.date_range,
              const Color(0xFFFF9800),
            ),
            const Divider(height: 20),
            _buildReportRow(
              localizations.etLast30Days,
              '${state.etLast30Days} mm',
              Icons.calendar_month,
              const Color(0xFF9C27B0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
