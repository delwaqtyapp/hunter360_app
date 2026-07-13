import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import '../providers/scada_provider.dart';

class OperationCommandsPage extends ConsumerStatefulWidget {
  const OperationCommandsPage({super.key});
  @override
  ConsumerState<OperationCommandsPage> createState() => _OperationCommandsPageState();
}

class _OperationCommandsPageState extends ConsumerState<OperationCommandsPage> {
  String _deviceType = '1';
  String _selectedStation = '';
  final _durationController = TextEditingController();
  String _duration = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(scadaProvider.notifier).initialize());
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scadaProvider);
    final apiClient = ref.watch(apiClientProvider);
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

        // --- Manual Operation Header ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF47abd1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(l10n.manualOperation, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),

        // --- Start Event Header ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFe4e1dd),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(l10n.startEvent, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),

        // --- Device Type ---
        Text(l10n.deviceType, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _deviceTypeChip(l10n.station, '1')),
            const SizedBox(width: 8),
            Expanded(child: _deviceTypeChip(l10n.block, '2')),
            const SizedBox(width: 8),
            Expanded(child: _deviceTypeChip(l10n.pmv, '3')),
          ],
        ),
        const SizedBox(height: 14),

        // --- Station/Block/PMV Number ---
        TextField(
          decoration: InputDecoration(
            labelText: _deviceType == '1' ? l10n.stationNumber : _deviceType == '2' ? l10n.blockNumber : l10n.pmvNumber,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) => _selectedStation = v,
        ),
        const SizedBox(height: 10),

        // --- Duration ---
        TextField(
          controller: _durationController,
          decoration: InputDecoration(
            labelText: l10n.durationMinutes,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) => _duration = v,
        ),
        const SizedBox(height: 18),

        // --- Start/Stop Buttons ---
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _sendCommand(apiClient, state.selectedController, '1', l10n),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(l10n.start, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _sendCommand(apiClient, state.selectedController, '0', l10n),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(l10n.stop, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _sendCommand(ApiClient api, String controller, String value, AppLocalizations l10n) async {
    if (_selectedStation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.stationNumber), backgroundColor: Colors.orange));
      return;
    }
    try {
      final tag = '$controller.StartSingleManualEvent_DeviceType_Command';
      await api.post(ApiConstants.tagsWrite, data: [
        {'TagName': tag, 'RawValue': _deviceType},
      ], contentType: 'application/json');
      if (mounted) {
        final deviceName = _deviceType == '1' ? l10n.station : _deviceType == '2' ? l10n.block : l10n.pmv;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.commandSent}: $deviceName #$_selectedStation'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _controllerSelector(ScadaState state, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
      child: Row(children: [
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
            items: AppConstants.controllers.map((c) => DropdownMenuItem(value: c['id']!, child: Text('${c['id']} - ${c['name']}'))).toList(),
            onChanged: (v) { if (v != null) ref.read(scadaProvider.notifier).setController(v); },
          ),
        ),
      ]),
    );
  }

  Widget _deviceTypeChip(String label, String value) {
    final isSelected = _deviceType == value;
    return GestureDetector(
      onTap: () => setState(() => _deviceType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF47abd1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF47abd1) : Colors.grey.shade300),
        ),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 13))),
      ),
    );
  }
}
