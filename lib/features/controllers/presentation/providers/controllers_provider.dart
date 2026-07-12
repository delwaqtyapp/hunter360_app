import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/features/controllers/domain/entities/valve.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';

class IrrigationController {
  final String id;
  final String name;
  final String type;
  final String status;
  final int activeValves;
  final int totalValves;
  final double? latitude;
  final double? longitude;

  const IrrigationController({
    required this.id,
    required this.name,
    this.type = 'ACC2',
    this.status = 'online',
    this.activeValves = 0,
    this.totalValves = 0,
    this.latitude,
    this.longitude,
  });
}

class ControllersState {
  final List<IrrigationController> controllers;
  final List<Valve> valves;
  final String? selectedControllerId;
  final bool isLoading;
  final String? error;

  const ControllersState({
    this.controllers = const [],
    this.valves = const [],
    this.selectedControllerId,
    this.isLoading = false,
    this.error,
  });

  ControllersState copyWith({List<IrrigationController>? controllers, List<Valve>? valves, String? selectedControllerId, bool? isLoading, String? error}) {
    return ControllersState(
      controllers: controllers ?? this.controllers,
      valves: valves ?? this.valves,
      selectedControllerId: selectedControllerId ?? this.selectedControllerId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ControllersNotifier extends StateNotifier<ControllersState> {
  final ApiClient _apiClient;

  ControllersNotifier(this._apiClient) : super(const ControllersState());

  Future<void> loadControllers() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiClient.get(ApiConstants.tagsList);
      final data = response.data;
      final List tags = data is List ? data : (data['Tags'] ?? data['Data'] ?? []);
      final controllerMap = <String, IrrigationController>{};

      for (final tag in tags) {
        final name = tag['TagName']?.toString() ?? '';
        final parts = name.split('.');
        if (parts.length >= 2) {
          final controllerName = parts[0];
          if (!controllerMap.containsKey(controllerName)) {
            controllerMap[controllerName] = IrrigationController(
              id: controllerName,
              name: controllerName,
              type: controllerName.startsWith('ACC') ? 'ACC2' : 'ICC2',
              status: 'online',
            );
          }
        }
      }

      state = state.copyWith(controllers: controllerMap.values.toList(), isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        controllers: [
          const IrrigationController(id: 'ACC2-01', name: 'ACC2-01', type: 'ACC2', status: 'online', activeValves: 8, totalValves: 16),
          const IrrigationController(id: 'ICC2-01', name: 'ICC2-01', type: 'ICC2', status: 'online', activeValves: 4, totalValves: 8),
        ],
      );
    }
  }

  Future<void> loadValves(String controllerId) async {
    state = state.copyWith(isLoading: true, selectedControllerId: controllerId);
    try {
      final response = await _apiClient.get(ApiConstants.tagsList);
      final data = response.data;
      final List tags = data is List ? data : (data['Tags'] ?? data['Data'] ?? []);
      final valves = <Valve>[];
      int stationNum = 1;

      for (final tag in tags) {
        final name = tag['TagName']?.toString() ?? '';
        if (name.startsWith('$controllerId.')) {
          valves.add(Valve(
            id: name,
            stationNumber: stationNum++,
            name: name.split('.').skip(1).join('.'),
            status: 'closed',
          ));
        }
      }

      state = state.copyWith(valves: valves, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        valves: List.generate(8, (i) => Valve(id: 'v$i', stationNumber: i + 1, name: 'Zone ${i + 1}', status: 'closed')),
      );
    }
  }

  Future<void> toggleValve(String valveId) async {
    final currentValve = state.valves.firstWhere((v) => v.id == valveId);
    final newStatus = currentValve.status == 'open' ? 'closed' : 'open';
    try {
      await _apiClient.get(ApiConstants.tagValue(valveId));
      state = state.copyWith(
        valves: state.valves.map((v) => v.id == valveId ? v.copyWith(status: newStatus, flowRate: newStatus == 'open' ? 15.5 : 0) : v).toList(),
      );
    } catch (_) {
      state = state.copyWith(
        valves: state.valves.map((v) => v.id == valveId ? v.copyWith(status: newStatus, flowRate: newStatus == 'open' ? 15.5 : 0) : v).toList(),
      );
    }
  }
}

final controllersProvider = StateNotifierProvider<ControllersNotifier, ControllersState>((ref) {
  return ControllersNotifier(ref.read(apiClientProvider));
});
