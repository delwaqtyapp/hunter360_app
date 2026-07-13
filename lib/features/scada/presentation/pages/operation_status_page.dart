import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final c = state.selectedController;
    final irrigatingVal = realtime.getValue('$c.ReportAlarmsInformation_ControllerIrrigating_Status');
    final isIrrigating = irrigatingVal == '1';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _controllerSelector(state),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: isIrrigating ? [const Color(0xFF006589), const Color(0xFF47abd1)] : [Colors.grey.shade700, Colors.grey.shade500]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text('Master Valves', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Icon(isIrrigating ? Icons.play_circle : Icons.pause_circle, color: Colors.white, size: 48),
              const SizedBox(height: 8),
              Text(isIrrigating ? 'IRRIGATING' : 'NOT IRRIGATING', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _statTile('Active Alarms', '${state.alarms.where((a) => a['Ack']?.toString() != 'Acked').length}', Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _statTile('Total Alarms', '${state.alarms.length}', Colors.blue)),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Alarm Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF156082))),
        const SizedBox(height: 8),
        ...state.alarms.take(20).map((a) {
          final priority = a['Priority'] ?? 1;
          final color = priority >= 4 ? Colors.red : priority >= 2 ? Colors.orange : Colors.amber;
          return Card(
            margin: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              dense: true,
              leading: Container(width: 8, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
              title: Text(a['AlarmComment']?.toString() ?? '', style: const TextStyle(fontSize: 13)),
              subtitle: Text(a['AlarmTime']?.toString() ?? '', style: const TextStyle(fontSize: 11)),
              trailing: Text('P$priority', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          );
        }),
      ],
    );
  }

  Widget _controllerSelector(ScadaState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Row(
        children: [
          const Icon(Icons.settings_input_antenna, color: Color(0xFF156082)),
          const SizedBox(width: 12),
          const Text('Controller: ', style: TextStyle(fontWeight: FontWeight.w500)),
          DropdownButton<String>(
            value: state.selectedController,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'C000', child: Text('C000')),
              DropdownMenuItem(value: 'C001', child: Text('C001 - Lanova')),
              DropdownMenuItem(value: 'C002', child: Text('C002 - CBP')),
              DropdownMenuItem(value: 'C003', child: Text('C003 - KAI')),
            ],
            onChanged: (v) {
              if (v != null) ref.read(scadaProvider.notifier).setController(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ]),
    );
  }
}
