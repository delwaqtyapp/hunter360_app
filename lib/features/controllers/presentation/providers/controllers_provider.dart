import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/valve.dart';

class ControllersState {
  final List<Valve> valves;
  final String? selectedControllerId;
  final bool isLoading;
  final String? error;

  const ControllersState({
    this.valves = const [],
    this.selectedControllerId,
    this.isLoading = false,
    this.error,
  });

  ControllersState copyWith({List<Valve>? valves, String? selectedControllerId, bool? isLoading, String? error}) {
    return ControllersState(
      valves: valves ?? this.valves,
      selectedControllerId: selectedControllerId ?? this.selectedControllerId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ControllersNotifier extends StateNotifier<ControllersState> {
  ControllersNotifier() : super(const ControllersState());

  Future<void> loadValves(String controllerId) async {
    state = state.copyWith(isLoading: true, selectedControllerId: controllerId);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      isLoading: false,
      valves: List.generate(8, (i) => Valve(
        id: 'v$i',
        stationNumber: i + 1,
        name: 'Zone ${i + 1}',
        status: i % 3 == 0 ? 'open' : 'closed',
        flowRate: i % 3 == 0 ? 15.5 + i * 2 : 0,
        runtime: i % 3 == 0 ? 30 + i * 5 : 0,
      )),
    );
  }

  Future<void> toggleValve(String valveId) async {
    final updated = state.valves.map((v) {
      if (v.id == valveId) {
        final newStatus = v.status == 'open' ? 'closed' : 'open';
        return v.copyWith(status: newStatus, flowRate: newStatus == 'open' ? 15.5 : 0);
      }
      return v;
    }).toList();
    state = state.copyWith(valves: updated);
  }
}

final controllersProvider = StateNotifierProvider<ControllersNotifier, ControllersState>((ref) {
  return ControllersNotifier();
});
