import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';

class FlowPage extends ConsumerStatefulWidget {
  const FlowPage({super.key});

  @override
  ConsumerState<FlowPage> createState() => _FlowPageState();
}

class _FlowPageState extends ConsumerState<FlowPage> {
  String _selectedController = '';
  List<FlSpot> _flowData = [];
  final List<FlSpot> _flowHistory = [];
  double _thresholdMin = 10.0;
  double _thresholdMax = 100.0;

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF156082),
        title: Text(
          localizations.flowManagement,
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
          _buildControllerSelector(localizations),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFlowOverviewCard(localizations),
                const SizedBox(height: 16),
                _buildFlowChart(localizations),
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
                  value: _selectedController.isNotEmpty ? _selectedController : null,
                  hint: Text(localizations.selectController),
                  items: AppConstants.controllers.map((c) {
                    return DropdownMenuItem(
                      value: c['id']!,
                      child: Text('${c['id']} - ${c['name']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedController = value;
                      });
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

  Widget _buildFlowOverviewCard(AppLocalizations localizations) {
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
                Text(
                  localizations.flowOverview,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewStat(
                  localizations.totalFlowRate,
                  '185.5 L/min',
                  Icons.speed,
                ),
                _buildOverviewStat(
                  localizations.activeFlowMeters,
                  '8 / 12',
                  Icons.sensors,
                ),
                _buildOverviewStat(
                  localizations.status,
                  localizations.normal,
                  Icons.check_circle,
                ),
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
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
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
                Text(
                  localizations.flowChart,
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
                    color: const Color(0xFF156082).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '24H',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF156082),
                    ),
                  ),
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
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          final hours = ['00', '04', '08', '12', '16', '20', '24'];
                          final index = (value / 4).toInt();
                          if (index >= 0 && index < hours.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                hours[index],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
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
                        reservedSize: 40,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          );
                        },
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF156082), Color(0xFF2196F3)],
                      ),
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
                Text(
                  localizations.flowMeters,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                Text(
                  '${flowMeters.where((m) => m['status'] == 'active').length} ${localizations.active}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
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
                          Text(
                            meter['name']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isActive ? localizations.flowing : localizations.stopped,
                            style: TextStyle(
                              fontSize: 11,
                              color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          meter['rate']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isActive ? const Color(0xFF156082) : Colors.grey,
                          ),
                        ),
                        Text(
                          localizations.litersPerMinute,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
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
                Text(
                  localizations.thresholdSettings,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.minimumFlow,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: TextEditingController(text: _thresholdMin.toString()),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            suffixText: 'L/min',
                            suffixStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onChanged: (value) {
                            _thresholdMin = double.tryParse(value) ?? 10.0;
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
                      Text(
                        localizations.maximumFlow,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: TextEditingController(text: _thresholdMax.toString()),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            suffixText: 'L/min',
                            suffixStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onChanged: (value) {
                            _thresholdMax = double.tryParse(value) ?? 100.0;
                          },
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF156082),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  localizations.saveThresholds,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                Text(
                  localizations.flowAlerts,
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
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${alerts.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF9800),
                    ),
                  ),
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
                          Text(
                            alert['title']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            alert['message']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      alert['time']!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
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
                      Text(
                        localizations.noAlerts,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
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
}