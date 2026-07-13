import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/features/controllers/domain/entities/valve.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/utils/response_parser.dart';

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
  final List<Map<String, dynamic>> stationTags;
  final List<Map<String, dynamic>> blockTags;
  final String? selectedControllerId;
  final bool isLoading;
  final String? error;

  const ControllersState({
    this.controllers = const [],
    this.valves = const [],
    this.stationTags = const [],
    this.blockTags = const [],
    this.selectedControllerId,
    this.isLoading = false,
    this.error,
  });

  ControllersState copyWith({
    List<IrrigationController>? controllers,
    List<Valve>? valves,
    List<Map<String, dynamic>>? stationTags,
    List<Map<String, dynamic>>? blockTags,
    String? selectedControllerId,
    bool? isLoading,
    String? error,
  }) {
    return ControllersState(
      controllers: controllers ?? this.controllers,
      valves: valves ?? this.valves,
      stationTags: stationTags ?? this.stationTags,
      blockTags: blockTags ?? this.blockTags,
      selectedControllerId: selectedControllerId ?? this.selectedControllerId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ControllersNotifier extends StateNotifier<ControllersState> {
  final ApiClient _apiClient;

  static const _controllerNames = {
    'C000': 'Main',
    'C001': 'Lanova',
    'C002': 'CBP',
    'C003': 'KAI',
  };

  ControllersNotifier(this._apiClient) : super(const ControllersState());

  Future<void> loadControllers() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiClient.get(ApiConstants.tagsList);
      final tags = ResponseParser.parseTagsList(response.data);
      final controllerMap = <String, IrrigationController>{};

      for (final tag in tags) {
        var group = tag['Group']?.toString() ?? '';
        if (group.isEmpty) {
          final tagName = tag['TagName']?.toString() ?? '';
          group = ResponseParser.extractGroupId(tagName);
        }
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

  Future<void> loadStationsForController(String controllerId) async {
    state = state.copyWith(isLoading: true, selectedControllerId: controllerId);
    try {
      final response = await _apiClient.get(ApiConstants.tagsList);
      final tags = ResponseParser.parseTagsList(response.data);
      final stations = <Map<String, dynamic>>[];
      final blocks = <Map<String, dynamic>>[];
      final valves = <Valve>[];
      int stationNum = 1;

      for (final tag in tags) {
        var group = tag['Group']?.toString() ?? '';
        if (group.isEmpty) {
          final tagName = tag['TagName']?.toString() ?? '';
          group = ResponseParser.extractGroupId(tagName);
        }
        if (group != controllerId) continue;

        final name = tag['Name']?.toString() ?? tag['TagName']?.toString() ?? '';
        final lowerName = name.toLowerCase();
        if (lowerName.contains('station')) {
          stations.add(tag);
          valves.add(Valve(
            id: name,
            stationNumber: stationNum++,
            name: name.split('.').last.replaceAll(RegExp(r'[_]'), ' '),
            status: 'closed',
          ));
        } else if (lowerName.contains('block')) {
          blocks.add(tag);
        }
      }

      state = state.copyWith(
        valves: valves,
        stationTags: stations,
        blockTags: blocks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        valves: [],
        stationTags: [],
        blockTags: [],
        error: e.toString(),
      );
    }
  }

  Future<void> loadValves(String controllerId) async {
    await loadStationsForController(controllerId);
  }

  Future<void> toggleValve(String valveId) async {
    final currentValve = state.valves.firstWhere(
      (v) => v.id == valveId,
      orElse: () => const Valve(id: '', stationNumber: 0, name: '', status: 'closed'),
    );
    final newStatus = currentValve.status == 'open' ? 'closed' : 'open';
    try {
      await _apiClient.post(
        ApiConstants.tagsWrite,
        data: [{'TagName': valveId, 'RawValue': newStatus == 'open' ? '1' : '0'}],
      );
      state = state.copyWith(
        valves: state.valves.map((v) => v.id == valveId
            ? v.copyWith(status: newStatus, flowRate: newStatus == 'open' ? 15.5 : 0)
            : v,
        ).toList(),
      );
    } catch (_) {
      state = state.copyWith(
        valves: state.valves.map((v) => v.id == valveId
            ? v.copyWith(status: newStatus, flowRate: newStatus == 'open' ? 15.5 : 0)
            : v,
        ).toList(),
      );
    }
  }
}

final controllersProvider = StateNotifierProvider<ControllersNotifier, ControllersState>((ref) {
  return ControllersNotifier(ref.read(apiClientProvider));
});
