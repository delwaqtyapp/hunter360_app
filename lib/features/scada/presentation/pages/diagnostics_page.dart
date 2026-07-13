import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/scada_provider.dart';

class DiagnosticsPage extends ConsumerStatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  ConsumerState<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends ConsumerState<DiagnosticsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(scadaProvider.notifier).initialize());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scadaProvider);
    final realtime = ref.watch(realtimeServiceProvider);
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _controllerSelector(state, l10n),
        const SizedBox(height: 10),

        // --- Controller Info Card ---
        _buildControllerInfoCard(l10n, state),
        const SizedBox(height: 14),

        // --- Alarm Section ---
        _sectionTitle(l10n.controllerAlarm, Colors.red),
        const SizedBox(height: 6),
        ...ref.read(scadaProvider.notifier).diagnosticItems.map((item) {
          final value = realtime.getValue(item['tagName']!);
          final isOn = value == '1';
          return _ledRow(item['label']!, isOn, Colors.red.shade700);
        }),
        const SizedBox(height: 16),

        // --- Info Section ---
        _sectionTitle(l10n.controllerInfo, Colors.green),
        const SizedBox(height: 6),
        ...ref.read(scadaProvider.notifier).infoItems.map((item) {
          final value = realtime.getValue(item['tagName']!);
          final isOn = value == '1';
          return _ledRow(item['label']!, isOn, Colors.green.shade600);
        }),
        const SizedBox(height: 16),

        // --- Module Information ---
        _sectionTitle(l10n.moduleInformation, Colors.blue),
        const SizedBox(height: 6),
        _buildModuleCards(l10n),
        const SizedBox(height: 16),

        // --- Current Draw Trend ---
        _sectionTitle(l10n.currentDrawTrend, Colors.teal),
        const SizedBox(height: 8),
        _buildCurrentDrawTrend(state),
        const SizedBox(height: 16),

        // --- Decoder Communication ---
        _sectionTitle(l10n.decoderCommunicationTitle, Colors.purple),
        const SizedBox(height: 6),
        _buildDecoderSection(l10n),
        const SizedBox(height: 16),

        // --- Block Settings ---
        _sectionTitle(l10n.blockSettingsTitle, Colors.orange),
        const SizedBox(height: 6),
        _buildBlockSettings(l10n),
      ],
    );
  }

  Widget _controllerSelector(ScadaState state, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          const Icon(Icons.settings_input_antenna, color: Color(0xFF156082), size: 20),
          const SizedBox(width: 10),
          Text('${l10n.selectController}:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: state.selectedController,
              underline: const SizedBox(),
              isExpanded: true,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: AppConstants.controllers
                  .map((c) => DropdownMenuItem(value: c['id']!, child: Text('${c['id']} - ${c['name']}')))
                  .toList(),
              onChanged: (v) {
                if (v != null) ref.read(scadaProvider.notifier).setController(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _ledRow(String label, bool isOn, Color activeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOn ? activeColor.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isOn ? activeColor.withOpacity(0.3) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isOn ? activeColor : Colors.grey.shade300,
              shape: BoxShape.circle,
              boxShadow: isOn ? [BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 4)] : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: isOn ? FontWeight.w600 : FontWeight.normal)),
          ),
        ],
      ),
    );
  }

  Widget _buildControllerInfoCard(AppLocalizations l10n, ScadaState state) {
    final info = ref.read(scadaProvider.notifier).controllerInfoData;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3B4F), Color(0xFF156082)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('${l10n.controllerNumber}: ${state.selectedController}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white24, height: 16),
          _infoRow(l10n.controllerTypeLabelD, info['ControllerType'] ?? '-'),
          _infoRow(l10n.firmwareVersion, info['FirmwareVersion'] ?? '-'),
          _infoRow(l10n.stationSizeLabelD, info['StationSize'] ?? '-'),
          _infoRow(l10n.ipAddress, info['IPAddress'] ?? '-'),
          _infoRow(l10n.commProtocolLabel, info['CommunicationProtocol'] ?? '-'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
          ),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildModuleCards(AppLocalizations l10n) {
    final labels = [l10n.module1Label, l10n.module2Label, l10n.module3Label];
    final notifier = ref.read(scadaProvider.notifier);

    return Column(
      children: List.generate(3, (index) {
        final moduleData = notifier.getModuleInfo(index);
        final currentDraw = moduleData.firstWhere((e) => e['label'] == 'CurrentDraw', orElse: () => {'value': '-'});
        final overload = moduleData.firstWhere((e) => e['label'] == 'Overload', orElse: () => {'value': '0'});
        final pathStatus = moduleData.firstWhere((e) => e['label'] == 'PathStatus', orElse: () => {'value': '-'});
        final outputMode = moduleData.firstWhere((e) => e['label'] == 'OutputMode', orElse: () => {'value': '-'});

        final isOverloaded = overload['value'] == '1';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isOverloaded ? Colors.red.shade300 : Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: isOverloaded ? Colors.red.withOpacity(0.08) : Colors.black.withOpacity(0.03),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF156082).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.developer_board, color: Color(0xFF156082), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(labels[index], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isOverloaded ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isOverloaded ? Colors.red : Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOverloaded ? l10n.overloadLabel : l10n.normalStatusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isOverloaded ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _moduleStat(l10n.currentDraw, '${currentDraw['value']} ${l10n.mAUnit}', Colors.blue),
                  const SizedBox(width: 8),
                  _moduleStat(l10n.pathStatus, pathStatus['value'] ?? '-', Colors.teal),
                  const SizedBox(width: 8),
                  _moduleStat(l10n.outputMode, outputMode['value'] ?? '-', Colors.orange),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _moduleStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentDrawTrend(ScadaState state) {
    final history = state.currentDrawHistory;
    if (history.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: const Center(child: Text('Collecting data...', style: TextStyle(color: Colors.grey))),
      );
    }

    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    final minY = history.reduce((a, b) => a < b ? a : b);
    final maxY = history.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: LineChart(
        LineChartData(
          minY: minY > 0 ? minY - 5 : 0,
          maxY: maxY + 5,
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: (maxY - minY) > 0 ? (maxY - minY) / 4 : 1),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF156082),
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF156082).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecoderSection(AppLocalizations l10n) {
    final decoder = ref.read(scadaProvider.notifier).decoderInfo;
    final commPct = double.tryParse(decoder['commPercentage'] ?? '0') ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Communication bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${l10n.commPercentage}: ${commPct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: commPct / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          commPct >= 80 ? Colors.green : commPct >= 50 ? Colors.orange : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _decoderStat(l10n.totalDecoders, decoder['totalDecoders'] ?? '0', Icons.devices),
              const SizedBox(width: 10),
              _decoderStat(l10n.activeDecodersCount, decoder['activeDecoders'] ?? '0', Icons.check_circle_outline),
              const SizedBox(width: 10),
              _decoderStat(l10n.decoderWireTest, decoder['wireTest'] ?? '0', Icons.bug_report_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _decoderStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.purple.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Colors.purple.shade400),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockSettings(AppLocalizations l10n) {
    final notifier = ref.read(scadaProvider.notifier);

    return Column(
      children: List.generate(6, (index) {
        final blockData = notifier.getBlockInfo(index);
        final cycleTime = blockData.firstWhere((e) => e['label'] == 'CycleTime', orElse: () => {'value': '-'});
        final soakTime = blockData.firstWhere((e) => e['label'] == 'SoakTime', orElse: () => {'value': '-'});
        final hydraulic = blockData.firstWhere((e) => e['label'] == 'HydraulicConnection', orElse: () => {'value': '0'});
        final masterValve = blockData.firstWhere((e) => e['label'] == 'MasterValve', orElse: () => {'value': '-'});
        final linkFlow = blockData.firstWhere((e) => e['label'] == 'LinkFlowZone', orElse: () => {'value': '-'});

        final isConnected = hydraulic['value'] == '1';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF156082).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF156082)))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text('${l10n.blockNumberLabel} ${index + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: isConnected ? Colors.green : Colors.grey, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(isConnected ? l10n.connectedLabel : l10n.disconnectedLabel, style: TextStyle(fontSize: 10, color: isConnected ? Colors.green.shade700 : Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _blockTag(l10n.cycleSettings, cycleTime['value'] ?? '-'),
                  const SizedBox(width: 8),
                  _blockTag(l10n.soakSettings, soakTime['value'] ?? '-'),
                  const SizedBox(width: 8),
                  _blockTag(l10n.masterValveAssoc, masterValve['value'] ?? '-'),
                  const SizedBox(width: 8),
                  _blockTag(l10n.linkFlowZone, linkFlow['value'] ?? '-'),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _blockTag(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
