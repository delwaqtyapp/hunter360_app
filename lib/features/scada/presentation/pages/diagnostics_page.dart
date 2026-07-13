import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _controllerSelector(state),
        const SizedBox(height: 16),
        _sectionTitle('Controller Alarm', Colors.red),
        const SizedBox(height: 8),
        ...ref.read(scadaProvider.notifier).diagnosticItems.map((item) {
          final value = realtime.getValue(item['tagName']!);
          final isOn = value == '1';
          return _ledRow(item['label']!, isOn, Colors.red.shade700);
        }),
        const SizedBox(height: 20),
        _sectionTitle('Controller Information', Colors.green),
        const SizedBox(height: 8),
        ...ref.read(scadaProvider.notifier).infoItems.map((item) {
          final value = realtime.getValue(item['tagName']!);
          final isOn = value == '1';
          return _ledRow(item['label']!, isOn, Colors.green.shade600);
        }),
      ],
    );
  }

  Widget _controllerSelector(ScadaState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
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

  Widget _sectionTitle(String title, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _ledRow(String label, bool isOn, Color activeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isOn ? activeColor.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isOn ? activeColor.withOpacity(0.3) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isOn ? activeColor : Colors.grey.shade300,
              shape: BoxShape.circle,
              boxShadow: isOn ? [BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 6)] : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: isOn ? FontWeight.w600 : FontWeight.normal))),
        ],
      ),
    );
  }
}
