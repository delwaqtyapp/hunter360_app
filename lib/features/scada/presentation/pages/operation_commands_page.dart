import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
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
  String _duration = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(scadaProvider.notifier).initialize());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scadaProvider);
    final apiClient = ref.watch(apiClientProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _controllerSelector(state),
        const SizedBox(height: 16),
        _headerTile('Manual Operation', const Color(0xFF47abd1)),
        const SizedBox(height: 12),
        _headerTile('Start Event', const Color(0xFFe4e1dd), textColor: Colors.black87),
        const SizedBox(height: 16),
        const Text('Device Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            _deviceTypeChip('Station', '1'),
            const SizedBox(width: 8),
            _deviceTypeChip('Block', '2'),
            const SizedBox(width: 8),
            _deviceTypeChip('P/MV', '3'),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: _deviceType == '1' ? 'Station Number' : _deviceType == '2' ? 'Block Number' : 'P/MV Number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) => _selectedStation = v,
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Duration (minutes)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) => _duration = v,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _sendCommand(apiClient, state.selectedController, '1'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('START', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _sendCommand(apiClient, state.selectedController, '0'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('STOP', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _sendCommand(ApiClient api, String controller, String value) async {
    if (_selectedStation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a number'), backgroundColor: Colors.orange));
      return;
    }
    try {
      final tag = '$controller.StartSingleManualEvent_DeviceType_Command';
      await api.post(ApiConstants.tagsWrite, data: [
        {'TagName': tag, 'RawValue': _deviceType},
      ], contentType: 'application/json');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Command sent: ${_deviceType == "1" ? "Station" : _deviceType == "2" ? "Block" : "P/MV"} #$_selectedStation'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _controllerSelector(ScadaState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Row(children: [
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
          onChanged: (v) { if (v != null) ref.read(scadaProvider.notifier).setController(v); },
        ),
      ]),
    );
  }

  Widget _headerTile(String title, Color color, {Color textColor = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(title, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _deviceTypeChip(String label, String value) {
    final isSelected = _deviceType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _deviceType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF47abd1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? const Color(0xFF47abd1) : Colors.grey.shade300),
          ),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }
}
