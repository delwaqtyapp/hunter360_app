import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import '../../domain/entities/controller.dart';

class DashboardState {
  final List<ControllerEntity> controllers;
  final int totalTags;
  final int activeAlarms;
  final bool isLoading;
  final String? error;

  const DashboardState({this.controllers = const [], this.totalTags = 0, this.activeAlarms = 0, this.isLoading = false, this.error});

  DashboardState copyWith({List<ControllerEntity>? controllers, int? totalTags, int? activeAlarms, bool? isLoading, String? error}) {
    return DashboardState(controllers: controllers ?? this.controllers, totalTags: totalTags ?? this.totalTags, activeAlarms: activeAlarms ?? this.activeAlarms, isLoading: isLoading ?? this.isLoading, error: error);
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ApiClient _apiClient;

  static const _controllerNames = {'C001': 'Lanova', 'C002': 'CBP', 'C003': 'KAI'};

  DashboardNotifier(this._apiClient) : super(const DashboardState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final tagsResponse = await _apiClient.get(ApiConstants.tagsList);
      final tagsData = tagsResponse.data;
      final List tags = (tagsData is Map) ? (tagsData['Tags'] ?? tagsData['Data'] ?? []) : [];
      final controllerMap = <String, int>{};
      for (final tag in tags) {
        final group = tag['Group']?.toString() ?? '';
        if (group.isEmpty) continue;
        controllerMap[group] = (controllerMap[group] ?? 0) + 1;
      }
      final controllers = controllerMap.entries.map((e) => ControllerEntity(id: e.key, name: _controllerNames[e.key] ?? e.key, model: e.key, status: 'online', ipAddress: '', valveCount: e.value, activeValves: 0, lastSeen: DateTime.now())).toList();
      int activeAlarms = 0;
      try {
        final alarmsResponse = await _apiClient.get(ApiConstants.alarmsCurrent);
        final alarmsData = alarmsResponse.data;
        final List alarmsList = (alarmsData is Map) ? (alarmsData['Alarms'] ?? alarmsData['Data'] ?? []) : [];
        activeAlarms = alarmsList.length;
      } catch (_) {}
      state = state.copyWith(isLoading: false, controllers: controllers, totalTags: tags.length, activeAlarms: activeAlarms);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final notifier = DashboardNotifier(ref.read(apiClientProvider));
  notifier.loadDashboard();
  return notifier;
});
