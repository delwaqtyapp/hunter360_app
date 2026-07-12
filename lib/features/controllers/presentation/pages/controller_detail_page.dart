import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/controllers_provider.dart';
import '../widgets/valve_status.dart';
import '../widgets/manual_operation_panel.dart';

class ControllerDetailPage extends ConsumerStatefulWidget {
  final String controllerId;
  const ControllerDetailPage({super.key, required this.controllerId});

  @override
  ConsumerState<ControllerDetailPage> createState() => _ControllerDetailPageState();
}

class _ControllerDetailPageState extends ConsumerState<ControllerDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(controllersProvider.notifier).loadValves(widget.controllerId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(controllersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controller Detail'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(controllersProvider.notifier).loadValves(widget.controllerId)),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusCard(state),
                  const SizedBox(height: 16),
                  const ManualOperationPanel(),
                  const SizedBox(height: 16),
                  const Text('Zones / Valves', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...state.valves.map((valve) => ValveStatusCard(
                    valve: valve,
                    onToggle: () => ref.read(controllersProvider.notifier).toggleValve(valve.id),
                  )),
                ],
              ),
            ),
    );
  }

  Widget _statusCard(ControllersState state) {
    final openCount = state.valves.where((v) => v.isOpen).length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1B5E20), const Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Controller Status', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusItem('Active', '$openCount', Icons.play_circle),
              _statusItem('Inactive', '${state.valves.length - openCount}', Icons.pause_circle),
              _statusItem('Total', '${state.valves.length}', Icons.grid_view),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
