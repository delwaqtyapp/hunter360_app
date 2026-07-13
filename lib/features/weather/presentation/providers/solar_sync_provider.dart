import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';

class SolarSyncReading {
  final DateTime timestamp;
  final double etValue;

  const SolarSyncReading({required this.timestamp, required this.etValue});
}

class SolarSyncState {
  final String selectedController;
  final bool sensorEnabled;
  final int selectedRegion;
  final double waterAdjustmentFactor;
  final int delayDays;
  final bool adjustmentDuringDelay;
  final String solarRadiation;
  final String temperature;
  final String humidity;
  final String windSpeed;
  final String etValue;
  final String rainfallToday;
  final List<SolarSyncReading> etHistory;
  final bool isSaving;
  final String? saveMessage;

  const SolarSyncState({
    this.selectedController = 'C001',
    this.sensorEnabled = true,
    this.selectedRegion = 1,
    this.waterAdjustmentFactor = 100.0,
    this.delayDays = 0,
    this.adjustmentDuringDelay = true,
    this.solarRadiation = '--',
    this.temperature = '--',
    this.humidity = '--',
    this.windSpeed = '--',
    this.etValue = '--',
    this.rainfallToday = '--',
    this.etHistory = const [],
    this.isSaving = false,
    this.saveMessage,
  });

  SolarSyncState copyWith({
    String? selectedController,
    bool? sensorEnabled,
    int? selectedRegion,
    double? waterAdjustmentFactor,
    int? delayDays,
    bool? adjustmentDuringDelay,
    String? solarRadiation,
    String? temperature,
    String? humidity,
    String? windSpeed,
    String? etValue,
    String? rainfallToday,
    List<SolarSyncReading>? etHistory,
    bool? isSaving,
    String? saveMessage,
  }) {
    return SolarSyncState(
      selectedController: selectedController ?? this.selectedController,
      sensorEnabled: sensorEnabled ?? this.sensorEnabled,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      waterAdjustmentFactor: waterAdjustmentFactor ?? this.waterAdjustmentFactor,
      delayDays: delayDays ?? this.delayDays,
      adjustmentDuringDelay: adjustmentDuringDelay ?? this.adjustmentDuringDelay,
      solarRadiation: solarRadiation ?? this.solarRadiation,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      etValue: etValue ?? this.etValue,
      rainfallToday: rainfallToday ?? this.rainfallToday,
      etHistory: etHistory ?? this.etHistory,
      isSaving: isSaving ?? this.isSaving,
      saveMessage: saveMessage,
    );
  }

  List<String> get settingTags => [
    '$selectedController.SolarSync.Enable',
    '$selectedController.SolarSync.Region',
    '$selectedController.SolarSync.WaterAdj',
    '$selectedController.SolarSync.DelayDays',
    '$selectedController.SolarSync.AdjDuringDelay',
  ];

  List<String> get readingTags => [
    '$selectedController.SolarSync.SolarRadiation',
    '$selectedController.SolarSync.Temperature',
    '$selectedController.SolarSync.Humidity',
    '$selectedController.SolarSync.WindSpeed',
    '$selectedController.SolarSync.ET',
    '$selectedController.SolarSync.Rainfall',
  ];
}

class SolarSyncNotifier extends StateNotifier<SolarSyncState> {
  final RealtimeService _realtimeService;
  final ApiClient _apiClient;
  Timer? _pollTimer;

  static const int _maxEtHistory = 100;

  SolarSyncNotifier(this._realtimeService, this._apiClient) : super(const SolarSyncState()) {
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchReadings());
  }

  Future<void> _fetchReadings() async {
    final tags = state.readingTags;
    if (tags.isEmpty) return;

    try {
      _realtimeService.subscribe(tags);
      final now = DateTime.now();

      final updatedHistory = List<SolarSyncReading>.from(state.etHistory);

      final etVal = _realtimeService.getValue(tags[4]);
      if (etVal.isNotEmpty && etVal != '--') {
        final parsed = double.tryParse(etVal);
        if (parsed != null) {
          updatedHistory.add(SolarSyncReading(timestamp: now, etValue: parsed));
          if (updatedHistory.length > _maxEtHistory) {
            updatedHistory.removeAt(0);
          }
        }
      }

      state = state.copyWith(
        solarRadiation: _realtimeService.getValue(tags[0]),
        temperature: _realtimeService.getValue(tags[1]),
        humidity: _realtimeService.getValue(tags[2]),
        windSpeed: _realtimeService.getValue(tags[3]),
        etValue: etVal,
        rainfallToday: _realtimeService.getValue(tags[5]),
        etHistory: updatedHistory,
      );
    } catch (_) {}
  }

  void setController(String controllerId) {
    state = state.copyWith(
      selectedController: controllerId,
      etHistory: [],
    );
    _fetchAndLoadSettings();
  }

  void setSensorEnabled(bool enabled) {
    state = state.copyWith(sensorEnabled: enabled);
  }

  void setRegion(int region) {
    state = state.copyWith(selectedRegion: region);
  }

  void setWaterAdjustmentFactor(double factor) {
    state = state.copyWith(waterAdjustmentFactor: factor);
  }

  void setDelayDays(int days) {
    state = state.copyWith(delayDays: days);
  }

  void setAdjustmentDuringDelay(bool value) {
    state = state.copyWith(adjustmentDuringDelay: value);
  }

  Future<void> _fetchAndLoadSettings() async {
    try {
      _realtimeService.subscribe(state.settingTags);
      final enableVal = _realtimeService.getValue(state.settingTags[0]);
      final regionVal = _realtimeService.getValue(state.settingTags[1]);
      final waterAdjVal = _realtimeService.getValue(state.settingTags[2]);
      final delayVal = _realtimeService.getValue(state.settingTags[3]);
      final adjDelayVal = _realtimeService.getValue(state.settingTags[4]);

      state = state.copyWith(
        sensorEnabled: enableVal == '1' || enableVal.toLowerCase() == 'true',
        selectedRegion: int.tryParse(regionVal) ?? 1,
        waterAdjustmentFactor: double.tryParse(waterAdjVal) ?? 100.0,
        delayDays: int.tryParse(delayVal) ?? 0,
        adjustmentDuringDelay: adjDelayVal == '1' || adjDelayVal.toLowerCase() == 'true',
      );
    } catch (_) {}
  }

  Future<void> saveSettings() async {
    state = state.copyWith(isSaving: true, saveMessage: null);
    try {
      final writes = [
        _writeTag(state.settingTags[0], state.sensorEnabled ? 1 : 0),
        _writeTag(state.settingTags[1], state.selectedRegion),
        _writeTag(state.settingTags[2], state.waterAdjustmentFactor.toInt()),
        _writeTag(state.settingTags[3], state.delayDays),
        _writeTag(state.settingTags[4], state.adjustmentDuringDelay ? 1 : 0),
      ];
      await Future.wait(writes);
      state = state.copyWith(isSaving: false, saveMessage: 'saved');
    } catch (_) {
      state = state.copyWith(isSaving: false, saveMessage: 'error');
    }
  }

  Future<void> _writeTag(String tagName, dynamic value) async {
    await _apiClient.post(ApiConstants.tagsWrite, data: {
      'tagName': tagName,
      'value': value,
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _realtimeService.unsubscribeAll();
    super.dispose();
  }
}

final solarSyncProvider = StateNotifierProvider<SolarSyncNotifier, SolarSyncState>((ref) {
  final realtimeService = ref.read(realtimeServiceProvider);
  final apiClient = ref.read(apiClientProvider);
  return SolarSyncNotifier(realtimeService, apiClient);
});
