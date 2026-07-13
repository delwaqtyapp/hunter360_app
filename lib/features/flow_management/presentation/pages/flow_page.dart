import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import '../providers/flow_provider.dart';

class FlowPage extends ConsumerStatefulWidget {
  const FlowPage({super.key});

  @override
  ConsumerState<FlowPage> createState() => _FlowPageState();
}

class _FlowPageState extends ConsumerState<FlowPage> {
  String _selectedController = '';
  List<FlSpot> _flowData = [];
  int _selectedZoneTab = 0;
  String _minThreshold = '';
  String _maxThreshold = '';

  @override
  void initState() {
    super.initState();
    if (AppConstants.controllers.isNotEmpty) {
      _selectedController = AppConstants.controllers.first['id']!;
    }
    _generateMockFlowData();
  }

  void _generateMockFlowData() {
    _flowData = List.generate(24, (index) {
      return FlSpot(
        index.toDouble(),
        30 + (index * 2.5) + (index % 3 == 0 ? 10 : 0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final flowState = ref.watch(flowManagementProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF156082),
        title: Text(
          localizations.flowManagement,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildControllerSelector(localizations),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFlowOverviewCard(localizations, flowState),
                const SizedBox(height: 16),
                _buildFlowChart(localizations),
                const SizedBox(height: 16),
                _buildLearnFlowSection(localizations, flowState),
                const SizedBox(height: 16),
                _buildHighFlowShutdownSection(localizations, flowState),
                const SizedBox(height: 16),
                _buildFlowZonesSection(localizations, flowState),
                const SizedBox(height: 16),
                _buildCycleAndSoakSection(localizations, flowState),
                const SizedBox(height: 16),
                _buildWaterSourceFlowSection(localizations, flowState),
                const SizedBox(height: 16),
                _buildFlowMetersList(localizations),
                const SizedBox(height: 16),
                _buildThresholdSettings(localizations),
                const SizedBox(height: 16),
                _buildFlowAlerts(localizations),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControllerSelector(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Icon(Icons.device_hub, color: const Color(0xFF156082), size: 20),
          const SizedBox(width: 8),
          Text(localizations.controller,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
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
                  value: _selectedController.isNotEmpty ? _selectedController : null,
                  hint: Text(localizations.selectController),
                  items: AppConstants.controllers.map((c) {
                    return DropdownMenuItem(value: c['id']!, child: Text('${c['id']} - ${c['name']}'));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedController = value);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowOverviewCard(AppLocalizations localizations, FlowManagementState flowState) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF156082), Color(0xFF1A7A9E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Text(localizations.flowOverview,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewStat(localizations.totalFlowRate, '185.5 L/min', Icons.speed),
                _buildOverviewStat(localizations.activeFlowMeters, '8 / 12', Icons.sensors),
                _buildOverviewStat(localizations.status, localizations.normal, Icons.check_circle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildFlowChart(AppLocalizations localizations) {
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
                Text(localizations.flowChart,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF156082).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('24H',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF156082))),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: const Color(0xFFF0F0F0), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          final hours = ['00', '04', '08', '12', '16', '20', '24'];
                          final index = (value / 4).toInt();
                          if (index >= 0 && index < hours.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(hours[index],
                                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 20,
                        getTitlesWidget: (value, meta) =>
                            Text('${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 24,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _flowData,
                      isCurved: true,
                      gradient: const LinearGradient(colors: [Color(0xFF156082), Color(0xFF2196F3)]),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF156082).withOpacity(0.3),
                            const Color(0xFF156082).withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnFlowSection(AppLocalizations localizations, FlowManagementState flowState) {
    final isLearning = flowState.learnFlowStatus == LearnFlowStatus.learning;
    final isComplete = flowState.learnFlowStatus == LearnFlowStatus.complete;

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
                const Icon(Icons.science, color: Color(0xFF9C27B0), size: 22),
                const SizedBox(width: 8),
                Text(localizations.learnFlow,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const Spacer(),
                _buildLearnFlowStatusChip(localizations, flowState),
              ],
            ),
            const SizedBox(height: 16),
            if (isLearning) ...[
              LinearProgressIndicator(
                value: flowState.learnFlowProgress / 100,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${flowState.learnFlowProgress.toInt()}%',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF9C27B0)),
              ),
              const SizedBox(height: 12),
            ],
            if (isComplete && flowState.learnFlowResults.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizations.learnFlowResults,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50))),
                    const SizedBox(height: 8),
                    ...flowState.learnFlowResults.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: const TextStyle(fontSize: 12)),
                            Text(e.value,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF156082))),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLearning
                    ? null
                    : () {
                        if (isComplete) {
                          ref.read(flowManagementProvider.notifier).resetLearnFlow();
                        } else {
                          ref.read(flowManagementProvider.notifier).startLearnFlow();
                        }
                      },
                icon: Icon(isLearning ? Icons.hourglass_empty : (isComplete ? Icons.refresh : Icons.play_arrow)),
                label: Text(
                  isLearning
                      ? localizations.learning
                      : (isComplete ? localizations.retry : localizations.startLearnFlow),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLearning ? Colors.grey : const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnFlowStatusChip(AppLocalizations localizations, FlowManagementState flowState) {
    Color color;
    String label;
    switch (flowState.learnFlowStatus) {
      case LearnFlowStatus.idle:
        color = Colors.grey;
        label = localizations.idle;
        break;
      case LearnFlowStatus.learning:
        color = const Color(0xFFFF9800);
        label = localizations.learning;
        break;
      case LearnFlowStatus.complete:
        color = const Color(0xFF4CAF50);
        label = localizations.learnComplete;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildHighFlowShutdownSection(AppLocalizations localizations, FlowManagementState flowState) {
    final config = flowState.highFlowShutdown;

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
                Icon(Icons.power_settings_new,
                    color: config.isActive ? const Color(0xFFE53935) : const Color(0xFF666666), size: 22),
                const SizedBox(width: 8),
                Text(localizations.highFlowShutdown,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const Spacer(),
                if (config.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(localizations.shutdownActive,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFE53935))),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(localizations.highFlowShutdownDesc,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(localizations.highFlowShutdown,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                Switch(
                  value: config.enabled,
                  activeColor: const Color(0xFFE53935),
                  onChanged: (_) {
                    ref.read(flowManagementProvider.notifier).toggleHighFlowShutdown();
                  },
                ),
              ],
            ),
            if (config.enabled) ...[
              const SizedBox(height: 12),
              _buildSettingRow(
                label: localizations.shutdownThreshold,
                value: '${config.threshold}',
                suffix: localizations.gpm,
                onChanged: (v) {
                  final val = double.tryParse(v);
                  if (val != null) {
                    ref.read(flowManagementProvider.notifier).updateShutdownThreshold(val);
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildSettingRow(
                label: localizations.autoResetTimer,
                value: '${config.autoResetMinutes}',
                suffix: localizations.minutesUnit,
                onChanged: (v) {
                  final val = int.tryParse(v);
                  if (val != null) {
                    ref.read(flowManagementProvider.notifier).updateAutoResetTimer(val);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required String label,
    required String value,
    required String suffix,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ),
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: TextEditingController(text: value),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              suffixText: suffix,
              suffixStyle: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFlowZonesSection(AppLocalizations localizations, FlowManagementState flowState) {
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
                const Icon(Icons.grid_on, color: Color(0xFF156082), size: 22),
                const SizedBox(width: 8),
                Text(localizations.flowZones,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: flowState.flowZones.length,
                itemBuilder: (context, index) {
                  final zone = flowState.flowZones[index];
                  final isSelected = _selectedZoneTab == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedZoneTab = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF156082) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF156082) : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getZoneStatusColor(zone.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Z${zone.index}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (flowState.flowZones.isNotEmpty) _buildZoneDetail(flowState.flowZones[_selectedZoneTab], localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneDetail(FlowZone zone, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getZoneStatusColor(zone.status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getZoneStatusColor(zone.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  zone.name.isEmpty ? 'Zone ${zone.index}' : zone.name,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _getZoneStatusColor(zone.status)),
                ),
              ),
              const Spacer(),
              _buildFlowStatusBadge(zone.status, localizations),
            ],
          ),
          const SizedBox(height: 12),
          _buildZoneDetailRow(localizations.flowTarget, '${zone.flowTarget} ${localizations.gpm}'),
          _buildZoneDetailRow(localizations.maxFlowLimit, '${zone.maxFlowLimit} ${localizations.gpm}'),
          _buildZoneDetailRow(localizations.overFlowLimit, '${zone.overFlowLimit} ${localizations.gpm}'),
          _buildZoneDetailRow(localizations.underFlowLimit, '${zone.underFlowLimit} ${localizations.gpm}'),
          _buildZoneDetailRow(localizations.unscheduledFlowLimit, '${zone.unscheduledFlowLimit} ${localizations.gpm}'),
          _buildZoneDetailRow(localizations.monthlyBudget, '${zone.monthlyBudget.toInt()} ${localizations.gallons}'),
          _buildZoneDetailRow(localizations.manualAllowance, '${zone.manualAllowance} ${localizations.minutesUnit}'),
          const Divider(height: 16),
          Row(
            children: [
              Text(localizations.flowPriority,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const Spacer(),
              SizedBox(
                width: 48,
                child: DropdownButton<int>(
                  value: zone.priority,
                  isDense: true,
                  underline: const SizedBox(),
                  items: List.generate(6, (i) => i + 1).map((p) {
                    return DropdownMenuItem(value: p, child: Text('$p'));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(flowManagementProvider.notifier).updateZonePriority(zone.index, v);
                    }
                  },
                ),
              ),
            ],
          ),
          if (zone.currentFlow > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.speed, size: 14, color: Color(0xFF156082)),
                const SizedBox(width: 4),
                Text(
                  '${localizations.flowRateLabel}: ${zone.currentFlow} ${localizations.gpm}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF156082)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildZoneDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          Text(value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
        ],
      ),
    );
  }

  Widget _buildFlowStatusBadge(FlowZoneStatus status, AppLocalizations localizations) {
    String label;
    Color color;
    switch (status) {
      case FlowZoneStatus.normal:
        label = localizations.flowStatusNormal;
        color = const Color(0xFF4CAF50);
        break;
      case FlowZoneStatus.high:
        label = localizations.flowStatusHigh;
        color = const Color(0xFFFF9800);
        break;
      case FlowZoneStatus.low:
        label = localizations.flowStatusLow;
        color = const Color(0xFFE53935);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Color _getZoneStatusColor(FlowZoneStatus status) {
    switch (status) {
      case FlowZoneStatus.normal:
        return const Color(0xFF4CAF50);
      case FlowZoneStatus.high:
        return const Color(0xFFFF9800);
      case FlowZoneStatus.low:
        return const Color(0xFFE53935);
    }
  }

  Widget _buildCycleAndSoakSection(AppLocalizations localizations, FlowManagementState flowState) {
    final config = flowState.cycleAndSoak;

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
                const Icon(Icons.autorenew, color: Color(0xFF009688), size: 22),
                const SizedBox(width: 8),
                Text(localizations.cycleAndSoak,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const Spacer(),
                Switch(
                  value: config.enabled,
                  activeColor: const Color(0xFF009688),
                  onChanged: (_) {
                    ref.read(flowManagementProvider.notifier).toggleCycleAndSoak();
                  },
                ),
              ],
            ),
            Text(localizations.cycleAndSoakDesc,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            if (config.enabled) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(localizations.cycleTime,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: TextEditingController(text: '${config.cycleTimeMinutes}'),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              suffixText: 'min',
                              suffixStyle: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            onChanged: (v) {
                              final val = int.tryParse(v);
                              if (val != null) {
                                ref.read(flowManagementProvider.notifier).updateCycleTime(val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(localizations.soakTime,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: TextEditingController(text: '${config.soakTimeMinutes}'),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              suffixText: 'min',
                              suffixStyle: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            onChanged: (v) {
                              final val = int.tryParse(v);
                              if (val != null) {
                                ref.read(flowManagementProvider.notifier).updateSoakTime(val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWaterSourceFlowSection(AppLocalizations localizations, FlowManagementState flowState) {
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
                const Icon(Icons.water, color: Color(0xFF2196F3), size: 22),
                const SizedBox(width: 8),
                Text(localizations.waterSourceFlow,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localizations.totalWaterSourceFlow,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: TextEditingController(
                              text: flowState.totalWaterSourceFlow.toStringAsFixed(1)),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixText: localizations.gpm,
                            suffixStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onChanged: (v) {
                            final val = double.tryParse(v);
                            if (val != null) {
                              ref.read(flowManagementProvider.notifier).updateTotalWaterSourceFlow(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(localizations.flowSensorMap,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
            const SizedBox(height: 8),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 32, color: Colors.grey[400]),
                    const SizedBox(height: 4),
                    Text(localizations.flowSensorMap,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowMetersList(AppLocalizations localizations) {
    final flowMeters = [
      {'name': 'Station 1 - Zone A', 'rate': '22.5 L/min', 'status': 'active'},
      {'name': 'Station 2 - Zone B', 'rate': '18.2 L/min', 'status': 'active'},
      {'name': 'Station 3 - Zone C', 'rate': '25.0 L/min', 'status': 'active'},
      {'name': 'Station 4 - Zone D', 'rate': '0.0 L/min', 'status': 'inactive'},
      {'name': 'Station 5 - Zone E', 'rate': '19.8 L/min', 'status': 'active'},
      {'name': 'Station 6 - Zone F', 'rate': '21.3 L/min', 'status': 'active'},
    ];

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
                const Icon(Icons.sensors, color: Color(0xFF156082), size: 22),
                const SizedBox(width: 8),
                Text(localizations.flowMeters,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const Spacer(),
                Text(
                  '${flowMeters.where((m) => m['status'] == 'active').length} ${localizations.active}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF4CAF50), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...flowMeters.map((meter) {
              final isActive = meter['status'] == 'active';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF4CAF50).withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF4CAF50).withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meter['name']!,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
                          const SizedBox(height: 2),
                          Text(
                            isActive ? localizations.flowing : localizations.stopped,
                            style: TextStyle(
                                fontSize: 11,
                                color: isActive ? const Color(0xFF4CAF50) : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(meter['rate']!,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isActive ? const Color(0xFF156082) : Colors.grey)),
                        Text(localizations.litersPerMinute,
                            style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      ],
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

  Widget _buildThresholdSettings(AppLocalizations localizations) {
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
                const Icon(Icons.tune, color: Color(0xFF156082), size: 22),
                const SizedBox(width: 8),
                Text(localizations.thresholdSettings,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localizations.minimumFlow, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            suffixText: 'L/min',
                            suffixStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onChanged: (v) => _minThreshold = v,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localizations.maximumFlow, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            suffixText: 'L/min',
                            suffixStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onChanged: (v) => _maxThreshold = v,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final minVal = double.tryParse(_minThreshold);
                  final maxVal = double.tryParse(_maxThreshold);
                  if (minVal != null && maxVal != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Thresholds saved: Min ${minVal.toStringAsFixed(1)} L/min, Max ${maxVal.toStringAsFixed(1)} L/min'), backgroundColor: Colors.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid min and max thresholds'), backgroundColor: Colors.orange),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF156082),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(localizations.saveThresholds,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowAlerts(AppLocalizations localizations) {
    final alerts = [
      {
        'title': localizations.lowFlowAlert,
        'message': '${localizations.station} 4 - ${localizations.flowBelowThreshold}',
        'time': '10 min ${localizations.ago}',
        'severity': 'warning',
      },
      {
        'title': localizations.highFlowAlert,
        'message': '${localizations.station} 3 - ${localizations.flowAboveNormal}',
        'time': '25 min ${localizations.ago}',
        'severity': 'info',
      },
    ];

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
                const Icon(Icons.warning_amber, color: Color(0xFFFF9800), size: 22),
                const SizedBox(width: 8),
                Text(localizations.flowAlerts,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${alerts.length}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFF9800))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.map((alert) {
              final isWarning = alert['severity'] == 'warning';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isWarning
                      ? const Color(0xFFFF9800).withOpacity(0.05)
                      : const Color(0xFF2196F3).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isWarning
                        ? const Color(0xFFFF9800).withOpacity(0.2)
                        : const Color(0xFF2196F3).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isWarning ? Icons.warning_amber : Icons.info_outline,
                      color: isWarning ? const Color(0xFFFF9800) : const Color(0xFF2196F3),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alert['title']!,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                          const SizedBox(height: 2),
                          Text(alert['message']!,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                        ],
                      ),
                    ),
                    Text(alert['time']!, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
              );
            }),
            if (alerts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(localizations.noAlerts,
                          style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
