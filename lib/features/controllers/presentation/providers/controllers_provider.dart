import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/features/controllers/domain/entities/valve.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';

class IrrigationController {
  final String id;
  final String name;
  final String displayName;
  final String type;
  final String status;
  final int activeValves;
  final int totalValves;
  final int tagCount;

  const IrrigationController({
    required this.id,
    required this.name,
    this.displayName = '',
    this.type = 'Controller',
    this.status = 'online',
    this.activeValves = 0,
    this.totalValves = 0,
    this.tagCount = 0,
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

  static const _controllerNames = {
    'C001': 'Lanova',
    'C002': 'CBP',
    'C003': 'KAI',
  };

  ControllersNotifier(this._apiClient) : super(const ControllersState());

  Future<void> loadControllers() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiClient.get(ApiConstants.tagsList);
      final data = response.data;
      final Map<String, dynamic> tagsMap = Map<String, dynamic>.from(data is Map ? data : {});
      final List tags = (tagsMap['Tags'] ?? tagsMap['Data'] ?? []) as List;
      final controllerMap = <String, IrrigationController>{};

      for (final tag in tags) {
        final tagMap = Map<String, dynamic>.from(tag is Map ? tag : {});
        final group = tagMap['Group']?.toString() ?? '';
        if (group.isEmpty) continue;

        if (!controllerMap.containsKey(group)) {
          final displayName = _controllerNames[group] ?? group;
          controllerMap[group] = IrrigationController(
            id: group,
            name: group,
            displayName: displayName,
            type: group,
            tagCount: 0,
          );
        }
        final existing = controllerMap[group]!;
        controllerMap[group] = IrrigationController(
          id: existing.id,
          name: existing.name,
          displayName: existing.displayName,
          type: existing.type,
          status: existing.status,
          tagCount: existing.tagCount + 1,
        );
      }

      state = state.copyWith(controllers: controllerMap.values.toList(), isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        controllers: [],
      );
    }
  }

  Future<void> loadValves(String controllerId) async {
    state = state.copyWith(isLoading: true, selectedControllerId: controllerId);
    try {
      final response = await _apiClient.get(ApiConstants.tagsList);
      final data = response.data;
      final Map<String, dynamic> tagsMap = Map<String, dynamic>.from(data is Map ? data : {});
      final List tags = (tagsMap['Tags'] ?? tagsMap['Data'] ?? []) as List;
      final valves = <Valve>[];
      int stationNum = 1;

      for (final tag in tags) {
        final tagMap = Map<String, dynamic>.from(tag is Map ? tag : {});
        final name = tagMap['Name']?.toString() ?? tagMap['TagName']?.toString() ?? '';
        final group = tagMap['Group']?.toString() ?? '';

        if (group == controllerId && name.toLowerCase().contains('station')) {
          valves.add(Valve(
            id: name,
            stationNumber: stationNum++,
            name: name.split('.').last,
            status: 'closed',
          ));
        }
      }

      state = state.copyWith(valves: valves, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        valves: [],
        error: e.toString(),
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
