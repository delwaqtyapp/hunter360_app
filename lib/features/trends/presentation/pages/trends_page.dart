import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/features/trends/presentation/providers/trends_provider.dart';

class TrendsPage extends ConsumerWidget {
  const TrendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trendsProvider);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF156082),
        title: Text(
          localizations.trendTitle,
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
          _buildTrendTypeSelector(context, ref, state, localizations),
          _buildTimeRangeSelector(context, ref, state, localizations),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTrendChart(context, state, localizations),
                const SizedBox(height: 16),
                _buildStatsCards(context, state, localizations),
                const SizedBox(height: 16),
                _buildTagLegend(context, state, localizations),
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
    TrendsState state,
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
                      ref.read(trendsProvider.notifier).setController(value);
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

  Widget _buildTrendTypeSelector(
    BuildContext context,
    WidgetRef ref,
    TrendsState state,
    AppLocalizations localizations,
  ) {
    final types = [
      {'type': TrendType.flow, 'label': localizations.trendFlow, 'icon': Icons.water_drop},
      {'type': TrendType.currentDraw, 'label': localizations.trendCurrentDraw, 'icon': Icons.electric_bolt},
      {'type': TrendType.seasonalAdjust, 'label': localizations.trendSeasonalAdjust, 'icon': Icons.calendar_month},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: types.map((t) {
          final isSelected = state.selectedTrendType == t['type'];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  ref.read(trendsProvider.notifier).setTrendType(t['type'] as TrendType);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF156082) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF156082) : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        t['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : const Color(0xFF666666),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeRangeSelector(
    BuildContext context,
    WidgetRef ref,
    TrendsState state,
    AppLocalizations localizations,
  ) {
    final ranges = [
      {'range': TimeRange.oneHour, 'label': '1H'},
      {'range': TimeRange.sixHours, 'label': '6H'},
      {'range': TimeRange.twentyFourHours, 'label': '24H'},
      {'range': TimeRange.sevenDays, 'label': '7D'},
      {'range': TimeRange.thirtyDays, 'label': '30D'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            localizations.timeRangeLabel,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(width: 12),
          ...ranges.map((r) {
            final isSelected = state.selectedTimeRange == r['range'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () {
                  ref.read(trendsProvider.notifier).setTimeRange(r['range'] as TimeRange);
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
          }),
        ],
      ),
    );
  }

  Widget _buildTrendChart(
    BuildContext context,
    TrendsState state,
    AppLocalizations localizations,
  ) {
    final tagColors = [
      [const Color(0xFF156082), const Color(0xFF2196F3)],
      [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
      [const Color(0xFF4CAF50), const Color(0xFF81C784)],
    ];

    final allPoints = <TrendDataPoint>[];
    for (final points in state.tagHistories.values) {
      allPoints.addAll(points);
    }

    double minX = 0;
    double maxX = 24;
    double minY = 0;
    double maxY = 100;

    if (allPoints.isNotEmpty) {
      final timestamps = allPoints.map((p) => p.timestamp.millisecondsSinceEpoch.toDouble()).toList();
      minX = timestamps.reduce((a, b) => a < b ? a : b);
      maxX = timestamps.reduce((a, b) => a > b ? a : b);
      if (minX == maxX) maxX = minX + 1;

      final values = allPoints.map((p) => p.value).toList();
      minY = values.reduce((a, b) => a < b ? a : b);
      maxY = values.reduce((a, b) => a > b ? a : b);
      final margin = (maxY - minY) * 0.1;
      if (margin > 0) {
        minY -= margin;
        maxY += margin;
      } else {
        minY -= 1;
        maxY += 1;
      }
    }

    final lineBars = <LineChartBarData>[];
    final tags = state.activeTags;
    for (int i = 0; i < tags.length; i++) {
      final points = state.tagHistories[tags[i]] ?? [];
      if (points.isEmpty) continue;
      final colors = tagColors[i % tagColors.length];
      lineBars.add(
        LineChartBarData(
          spots: points.map((p) {
            return FlSpot(
              p.timestamp.millisecondsSinceEpoch.toDouble(),
              p.value,
            );
          }).toList(),
          isCurved: true,
          gradient: LinearGradient(colors: colors),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                colors[0].withOpacity(0.2),
                colors[0].withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      );
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
                  _getTrendTitle(state.selectedTrendType, localizations),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (lineBars.isEmpty)
              SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    localizations.noData,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ),
              )
            else
              SizedBox(
                height: 220,
                child: LineChart(
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
                            final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                            final label = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 9, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
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
                    lineBarsData: lineBars,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final tagIndex = lineBars.indexOf(
                              lineBars.firstWhere((b) => b.spots.contains(spot)),
                            );
                            return LineTooltipItem(
                              '${spot.y.toStringAsFixed(2)}',
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                      handleBuiltInTouches: true,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(
    BuildContext context,
    TrendsState state,
    AppLocalizations localizations,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            localizations.trendMin,
            state.minValue?.toStringAsFixed(2) ?? '--',
            const Color(0xFF2196F3),
            Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            localizations.trendMax,
            state.maxValue?.toStringAsFixed(2) ?? '--',
            const Color(0xFFFF5722),
            Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            localizations.trendAverage,
            state.averageValue?.toStringAsFixed(2) ?? '--',
            const Color(0xFF4CAF50),
            Icons.analytics,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagLegend(
    BuildContext context,
    TrendsState state,
    AppLocalizations localizations,
  ) {
    final tagColors = [
      const Color(0xFF156082),
      const Color(0xFFFF9800),
      const Color(0xFF4CAF50),
    ];

    final tags = state.activeTags;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.trendActiveTags,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            ...tags.asMap().entries.map((entry) {
              final index = entry.key;
              final tag = entry.value;
              final currentVal = state.currentValues[tag] ?? '--';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tagColors[index % tagColors.length].withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: tagColors[index % tagColors.length].withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: tagColors[index % tagColors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tag.split('.').last,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    Text(
                      currentVal,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: tagColors[index % tagColors.length],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getTrendTitle(TrendType type, AppLocalizations localizations) {
    switch (type) {
      case TrendType.flow:
        return localizations.trendFlowChart;
      case TrendType.currentDraw:
        return localizations.trendCurrentDrawChart;
      case TrendType.seasonalAdjust:
        return localizations.trendSeasonalAdjustChart;
    }
  }
}
