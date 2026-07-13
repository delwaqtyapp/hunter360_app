import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
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
    final l10n = AppLocalizations.of(context);

    final controllerIndex = AppConstants.controllers.indexWhere((c) => c['id'] == state.selectedController);
    final controllerName = controllerIndex >= 0 ? AppConstants.controllers[controllerIndex]['name']! : state.selectedController;

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
            Text('${l10n.controllerNumber}: ${state.selectedController}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Text('${l10n.projectLabel}: $controllerName', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ]),
        ),
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
              items: AppConstants.controllers.map((c) => DropdownMenuItem(
                value: c['id']!,
                child: Text('${c['id']} - ${c['name']}'),
              )).toList(),
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
          Expanded(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: isOn ? FontWeight.w600 : FontWeight.normal))),
        ],
      ),
    );
  }
}
