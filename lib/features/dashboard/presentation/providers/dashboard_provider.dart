import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';
import '../../domain/entities/controller.dart';

class FlowSensorData {
  final String tag;
  final double value;
  final String unit;
  final String status;
  final List<double> history;

  const FlowSensorData({required this.tag, this.value = 0, this.unit = 'L/min', this.status = 'Normal', this.history = const []});

  FlowSensorData copyWith({double? value, String? status, List<double>? history}) {
    return FlowSensorData(tag: tag, value: value ?? this.value, unit: unit, status: status ?? this.status, history: history ?? this.history);
  }
}

class DashboardState {
  final List<ControllerEntity> controllers;
  final int totalTags;
  final int activeAlarms;
  final bool isLoading;
  final String? error;
  final Map<String, FlowSensorData> flowSensors;
  final Map<String, bool> irrigatingStatus;
  final bool isConnected;
  final int runningStations;

  const DashboardState({
    this.controllers = const [],
    this.totalTags = 0,
    this.activeAlarms = 0,
    this.isLoading = false,
    this.error,
    this.flowSensors = const {},
    this.irrigatingStatus = const {},
    this.isConnected = false,
    this.runningStations = 0,
  });

  DashboardState copyWith({
    List<ControllerEntity>? controllers,
    int? totalTags,
    int? activeAlarms,
    bool? isLoading,
    String? error,
    Map<String, FlowSensorData>? flowSensors,
    Map<String, bool>? irrigatingStatus,
    bool? isConnected,
    int? runningStations,
  }) {
    return DashboardState(
      controllers: controllers ?? this.controllers,
      totalTags: totalTags ?? this.totalTags,
      activeAlarms: activeAlarms ?? this.activeAlarms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      flowSensors: flowSensors ?? this.flowSensors,
      irrigatingStatus: irrigatingStatus ?? this.irrigatingStatus,
      isConnected: isConnected ?? this.isConnected,
      runningStations: runningStations ?? this.runningStations,
    );
  }

  double get totalFlowRate => flowSensors.values.fold(0.0, (sum, s) => sum + s.value);

  int get controllersOnlineCount => controllers.where((c) => c.isOnline).length;
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ApiClient _apiClient;
  final RealtimeService _realtimeService;
  StreamSubscription? _subscription;

  static const _controllerNames = {'C001': 'Lanova', 'C002': 'CBP', 'C003': 'KAI'};

  static const _flowTags = [
    'C001.FlowSensor1.FlowRate',
    'C001.FlowSensor2.FlowRate',
    'C001.FlowSensor3.FlowRate',
    'C002.FlowSensor1.FlowRate',
    'C002.FlowSensor2.FlowRate',
    'C002.FlowSensor3.FlowRate',
    'C002.FlowSensor4.FlowRate',
    'C002.FlowSensor5.FlowRate',
  ];

  static const _irrigatingTags = [
    'C001.Irrigating',
    'C002.Irrigating',
    'C003.Irrigating',
  ];

  static const _allTags = [..._flowTags, ..._irrigatingTags];

  DashboardNotifier(this._apiClient, this._realtimeService) : super(const DashboardState()) {
    _startRealtimeSubscription();
  }

  void _startRealtimeSubscription() {
    _realtimeService.updateInterval(2000);
    _realtimeService.subscribe(_allTags);

    _subscription = _realtimeService.tagValuesStream.listen((values) {
      final flowSensors = <String, FlowSensorData>{};
      final irrigatingStatus = <String, bool>{};

      for (final tag in _flowTags) {
        final tv = values[tag];
        final currentVal = tv != null ? (double.tryParse(tv.scaledValue) ?? 0.0) : 0.0;
        final existing = state.flowSensors[tag];
        final history = existing != null ? [...existing.history, currentVal] : [currentVal];
        final trimmed = history.length > 30 ? history.sublist(history.length - 30) : history;

        String status = 'Normal';
        if (currentVal > 80) status = 'High';
        else if (currentVal < 5 && currentVal > 0) status = 'Low';

        flowSensors[tag] = FlowSensorData(
          tag: tag,
          value: currentVal,
          status: status,
          history: trimmed,
        );
      }

      for (final tag in _irrigatingTags) {
        final tv = values[tag];
        irrigatingStatus[tag] = tv != null && (tv.scaledValue == '1' || tv.scaledValue.toLowerCase() == 'true');
      }

      int running = 0;
      for (final v in irrigatingStatus.values) {
        if (v) running++;
      }

      state = state.copyWith(
        flowSensors: flowSensors,
        irrigatingStatus: irrigatingStatus,
        isConnected: true,
        runningStations: running,
      );
    });
  }

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
      final controllers = controllerMap.entries
          .map((e) => ControllerEntity(
                id: e.key,
                name: _controllerNames[e.key] ?? e.key,
                model: e.key,
                status: 'online',
                ipAddress: '',
                valveCount: e.value,
                activeValves: 0,
                lastSeen: DateTime.now(),
              ))
          .toList();
      int activeAlarms = 0;
      try {
        final alarmsResponse = await _apiClient.get(ApiConstants.alarmsCurrent);
        final alarmsData = alarmsResponse.data;
        final List alarmsList = (alarmsData is Map) ? (alarmsData['Alarms'] ?? alarmsData['Data'] ?? []) : [];
        activeAlarms = alarmsList.length;
      } catch (_) {}
      state = state.copyWith(
        isLoading: false,
        controllers: controllers,
        totalTags: tags.length,
        activeAlarms: activeAlarms,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _realtimeService.unsubscribeAll();
    super.dispose();
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final notifier = DashboardNotifier(ref.read(apiClientProvider), ref.read(realtimeServiceProvider));
  notifier.loadDashboard();
  return notifier;
});
