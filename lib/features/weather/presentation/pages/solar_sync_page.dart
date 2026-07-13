import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/features/weather/presentation/providers/solar_sync_provider.dart';

class SolarSyncPage extends ConsumerWidget {
  const SolarSyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(solarSyncProvider);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF156082),
        title: Text(
          localizations.solarSyncTitle,
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
                _buildSettingsSection(context, ref, state, localizations),
                const SizedBox(height: 16),
                _buildReadingsSection(context, state, localizations),
                const SizedBox(height: 16),
                _buildETHistoryChart(context, state, localizations),
                const SizedBox(height: 16),
                _buildSaveButton(context, ref, state, localizations),
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
    SolarSyncState state,
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
                      ref.read(solarSyncProvider.notifier).setController(value);
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

  Widget _buildSettingsSection(
    BuildContext context,
    WidgetRef ref,
    SolarSyncState state,
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
                const Icon(Icons.settings, color: Color(0xFF156082), size: 22),
                const SizedBox(width: 8),
                Text(
                  localizations.solarSyncSettings,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEnableToggle(context, ref, state, localizations),
            const Divider(height: 24),
            _buildRegionSelector(context, ref, state, localizations),
            const Divider(height: 24),
            _buildWaterAdjustmentSlider(context, ref, state, localizations),
            const Divider(height: 24),
            _buildDelayDaysSetting(context, ref, state, localizations),
            const Divider(height: 24),
            _buildAdjustmentDuringDelayToggle(context, ref, state, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildEnableToggle(
    BuildContext context,
    WidgetRef ref,
    SolarSyncState state,
    AppLocalizations localizations,
  ) {
    return Row(
      children: [
        const Icon(Icons.power_settings_new, color: Color(0xFF4CAF50), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.solarSyncEnableSensor,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                localizations.solarSyncEnableSensorDesc,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Switch(
          value: state.sensorEnabled,
          activeColor: const Color(0xFF4CAF50),
          onChanged: (value) {
            ref.read(solarSyncProvider.notifier).setSensorEnabled(value);
          },
        ),
      ],
    );
  }

  Widget _buildRegionSelector(
    BuildContext context,
    WidgetRef ref,
    SolarSyncState state,
    AppLocalizations localizations,
  ) {
    return Row(
      children: [
        const Icon(Icons.public, color: Color(0xFF156082), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.solarSyncRegion,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: state.selectedRegion,
                    items: List.generate(10, (i) {
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text('${localizations.solarSyncRegionLabel} ${i + 1}'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(solarSyncProvider.notifier).setRegion(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaterAdjustmentSlider(
    BuildContext context,
    WidgetRef ref,
    SolarSyncState state,
    AppLocalizations localizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.water_drop, color: Color(0xFF2196F3), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizations.solarSyncWaterAdjustment,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF156082).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${state.waterAdjustmentFactor.toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF156082),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF156082),
            inactiveTrackColor: const Color(0xFFE0E0E0),
            thumbColor: const Color(0xFF156082),
            overlayColor: const Color(0xFF156082).withOpacity(0.1),
          ),
          child: Slider(
            value: state.waterAdjustmentFactor,
            min: 50,
            max: 200,
            divisions: 150,
            onChanged: (value) {
              ref.read(solarSyncProvider.notifier).setWaterAdjustmentFactor(value);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('50%', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            Text('200%', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  Widget _buildDelayDaysSetting(
    BuildContext context,
    WidgetRef ref,
    SolarSyncState state,
    AppLocalizations localizations,
  ) {
    return Row(
      children: [
        const Icon(Icons.schedule, color: Color(0xFFFF9800), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.solarSyncDelayDays,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                localizations.solarSyncDelayDaysDesc,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: state.delayDays > 0
                    ? () => ref.read(solarSyncProvider.notifier).setDelayDays(state.delayDays - 1)
                    : null,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${state.delayDays}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: state.delayDays < 14
                    ? () => ref.read(solarSyncProvider.notifier).setDelayDays(state.delayDays + 1)
                    : null,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustmentDuringDelayToggle(
    BuildContext context,
    WidgetRef ref,
    SolarSyncState state,
    AppLocalizations localizations,
  ) {
    return Row(
      children: [
        const Icon(Icons.tune, color: Color(0xFF9C27B0), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.solarSyncAdjDuringDelay,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                localizations.solarSyncAdjDuringDelayDesc,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Switch(
          value: state.adjustmentDuringDelay,
          activeColor: const Color(0xFF9C27B0),
          onChanged: (value) {
            ref.read(solarSyncProvider.notifier).setAdjustmentDuringDelay(value);
          },
        ),
      ],
    );
  }

  Widget _buildReadingsSection(
    BuildContext context,
    SolarSyncState state,
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
                const Icon(Icons.sensors, color: Color(0xFF4CAF50), size: 22),
                const SizedBox(width: 8),
                Text(
                  localizations.solarSyncReadings,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    localizations.solarSyncLive,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildReadingCard(
                  localizations.solarRadiation,
                  state.solarRadiation,
                  'W/m²',
                  const Color(0xFFFF9800),
                  Icons.wb_sunny,
                ),
                _buildReadingCard(
                  localizations.temperature,
                  state.temperature,
                  '°C',
                  const Color(0xFFFF5722),
                  Icons.thermostat,
                ),
                _buildReadingCard(
                  localizations.humidity,
                  state.humidity,
                  '%',
                  const Color(0xFF2196F3),
                  Icons.water_drop,
                ),
                _buildReadingCard(
                  localizations.windSpeed,
                  state.windSpeed,
                  'km/h',
                  const Color(0xFF4CAF50),
                  Icons.air,
                ),
                _buildReadingCard(
                  localizations.evapotranspiration,
                  state.etValue,
                  'mm',
                  const Color(0xFF03A9F4),
                  Icons.water,
                ),
                _buildReadingCard(
                  localizations.rainfall,
                  state.rainfallToday,
                  'mm',
                  const Color(0xFF9C27B0),
                  Icons.grain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingCard(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(fontSize: 9, color: Colors.grey[600]),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildETHistoryChart(
    BuildContext context,
    SolarSyncState state,
    AppLocalizations localizations,
  ) {
    final spots = state.etHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.etValue);
    }).toList();

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
                const Icon(Icons.show_chart, color: Color(0xFF03A9F4), size: 22),
                const SizedBox(width: 8),
                Text(
                  localizations.solarSyncETHistory,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
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
                              reservedSize: 24,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < state.etHistory.length) {
                                  final time = state.etHistory[index].timestamp;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 8, color: Colors.grey),
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
                              reservedSize: 32,
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

  Widget _buildSaveButton(
    BuildContext context,
    WidgetRef ref,
    SolarSyncState state,
    AppLocalizations localizations,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isSaving
                ? null
                : () async {
                    await ref.read(solarSyncProvider.notifier).saveSettings();
                    if (context.mounted) {
                      final msg = ref.read(solarSyncProvider).saveMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            msg == 'saved'
                                ? localizations.solarSyncSaveSuccess
                                : localizations.solarSyncSaveError,
                          ),
                          backgroundColor: msg == 'saved' ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF156082),
              disabledBackgroundColor: Colors.grey[400],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: state.isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    localizations.save,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
