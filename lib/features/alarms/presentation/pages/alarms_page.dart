import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/alarms_provider.dart';
import '../widgets/alarm_list_tile.dart';

class AlarmsPage extends ConsumerWidget {
  const AlarmsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alarmsProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _filterChip('All', 'all', state, ref),
                const SizedBox(width: 8),
                _filterChip('Active', 'active', state, ref),
                const SizedBox(width: 8),
                _filterChip('Critical', 'critical', state, ref),
                const SizedBox(width: 8),
                _filterChip('Warning', 'warning', state, ref),
              ],
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filteredAlarms.isEmpty
                    ? const Center(child: Text('No alarms'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.filteredAlarms.length,
                        itemBuilder: (context, index) {
                          return AlarmListTile(
                            alarm: state.filteredAlarms[index],
                            onAcknowledge: () => ref.read(alarmsProvider.notifier).acknowledgeAlarm(state.filteredAlarms[index].id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, AlarmsState state, WidgetRef ref) {
    return FilterChip(
      label: Text(label),
      selected: state.filter == value,
      onSelected: (_) => ref.read(alarmsProvider.notifier).setFilter(value),
      selectedColor: Colors.green.shade100,
    );
  }
}
