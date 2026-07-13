import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';
import '../providers/scada_provider.dart';

class OperationStatusPage extends ConsumerStatefulWidget {
  const OperationStatusPage({super.key});
  @override
  ConsumerState<OperationStatusPage> createState() => _OperationStatusPageState();
}

class _OperationStatusPageState extends ConsumerState<OperationStatusPage> {
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

    final c = state.selectedController;
    final irrigatingVal = realtime.getValue('$c.ReportAlarmsInformation_ControllerIrrigating_Status');
    final isIrrigating = irrigatingVal == '1';

    final controllerIndex = AppConstants.controllers.indexWhere((ct) => ct['id'] == c);
    final controllerName = controllerIndex >= 0 ? AppConstants.controllers[controllerIndex]['name']! : c;

    final activeAlarms = state.alarms.where((a) => a['Ack']?.toString() != 'Acked').length;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _controllerSelector(state, l10n),
        const SizedBox(height: 10),

        // --- Controller Info Bar ---
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF156082).withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline, color: Color(0xFF156082), size: 18),
            const SizedBox(width: 8),
            Text('${l10n.controllerNumber}: $c', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Text('${l10n.projectLabel}: $controllerName', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ]),
        ),
        const SizedBox(height: 14),

        // --- Irrigation Status Card ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: isIrrigating ? [const Color(0xFF006589), const Color(0xFF47abd1)] : [Colors.grey.shade700, Colors.grey.shade500]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(l10n.masterValves, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Icon(isIrrigating ? Icons.play_circle : Icons.pause_circle, color: Colors.white, size: 44),
              const SizedBox(height: 8),
              Text(isIrrigating ? l10n.irrigating : l10n.notIrrigating, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // --- Alarm Stats ---
        Row(
          children: [
            Expanded(child: _statTile(l10n.activeAlarmCount, '$activeAlarms', Colors.orange)),
            const SizedBox(width: 10),
            Expanded(child: _statTile(l10n.totalAlarmCount, '${state.alarms.length}', Colors.blue)),
          ],
        ),
        const SizedBox(height: 14),

        // --- Alarm List ---
        Text(l10n.alarmStatus, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF156082))),
        const SizedBox(height: 8),
        if (state.alarms.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(child: Text(l10n.noAlarms, style: TextStyle(color: Colors.grey.shade500))),
          )
        else
          ...state.alarms.take(20).map((a) {
            final priority = a['Priority'] ?? 1;
            final color = priority >= 4 ? Colors.red : priority >= 2 ? Colors.orange : Colors.amber;
            return Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                dense: true,
                leading: Container(width: 6, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                title: Text(a['AlarmComment']?.toString() ?? '', style: const TextStyle(fontSize: 12)),
                subtitle: Text(a['AlarmTime']?.toString() ?? '', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                trailing: Text('P$priority', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            );
          }),
      ],
    );
  }

  Widget _controllerSelector(ScadaState state, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
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
              items: AppConstants.controllers.map((ct) => DropdownMenuItem(value: ct['id']!, child: Text('${ct['id']} - ${ct['name']}'))).toList(),
              onChanged: (v) {
                if (v != null) ref.read(scadaProvider.notifier).setController(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.25))),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ]),
    );
  }
}
