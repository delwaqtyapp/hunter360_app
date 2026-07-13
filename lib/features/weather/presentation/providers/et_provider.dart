import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';

class ETDataPoint {
  final DateTime timestamp;
  final double value;

  const ETDataPoint({required this.timestamp, required this.value});
}

class ETState {
  final String selectedController;
  final String currentETo;
  final String temperature;
  final String humidity;
  final String windSpeed;
  final String solarRadiation;
  final String calculatedETo;
  final String dailyET;
  final String weeklyET;
  final String monthlyET;
  final String yearlyET;
  final String validETDays;
  final String etAverage;
  final String etLast7Days;
  final String etLast30Days;
  final List<ETDataPoint> etTrendData;
  final TimeRange selectedTimeRange;

  const ETState({
    this.selectedController = 'C001',
    this.currentETo = '--',
    this.temperature = '--',
    this.humidity = '--',
    this.windSpeed = '--',
    this.solarRadiation = '--',
    this.calculatedETo = '--',
    this.dailyET = '--',
    this.weeklyET = '--',
    this.monthlyET = '--',
    this.yearlyET = '--',
    this.validETDays = '--',
    this.etAverage = '--',
    this.etLast7Days = '--',
    this.etLast30Days = '--',
    this.etTrendData = const [],
    this.selectedTimeRange = TimeRange.twentyFourHours,
  });

  ETState copyWith({
    String? selectedController,
    String? currentETo,
    String? temperature,
    String? humidity,
    String? windSpeed,
    String? solarRadiation,
    String? calculatedETo,
    String? dailyET,
    String? weeklyET,
    String? monthlyET,
    String? yearlyET,
    String? validETDays,
    String? etAverage,
    String? etLast7Days,
    String? etLast30Days,
    List<ETDataPoint>? etTrendData,
    TimeRange? selectedTimeRange,
  }) {
    return ETState(
      selectedController: selectedController ?? this.selectedController,
      currentETo: currentETo ?? this.currentETo,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      solarRadiation: solarRadiation ?? this.solarRadiation,
      calculatedETo: calculatedETo ?? this.calculatedETo,
      dailyET: dailyET ?? this.dailyET,
      weeklyET: weeklyET ?? this.weeklyET,
      monthlyET: monthlyET ?? this.monthlyET,
      yearlyET: yearlyET ?? this.yearlyET,
      validETDays: validETDays ?? this.validETDays,
      etAverage: etAverage ?? this.etAverage,
      etLast7Days: etLast7Days ?? this.etLast7Days,
      etLast30Days: etLast30Days ?? this.etLast30Days,
      etTrendData: etTrendData ?? this.etTrendData,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
    );
  }

  List<String> get inputTags => [
    '$selectedController.ET.Temperature',
    '$selectedController.ET.Humidity',
    '$selectedController.ET.WindSpeed',
    '$selectedController.ET.SolarRadiation',
    '$selectedController.ET.CurrentETo',
    '$selectedController.ET.CalculatedETo',
  ];

  List<String> get accumulationTags => [
    '$selectedController.ET.Daily',
    '$selectedController.ET.Weekly',
    '$selectedController.ET.Monthly',
    '$selectedController.ET.Yearly',
  ];

  List<String> get reportTags => [
    '$selectedController.ET.ValidDays',
    '$selectedController.ET.Average',
    '$selectedController.ET.Last7Days',
    '$selectedController.ET.Last30Days',
  ];
}

enum TimeRange { oneHour, sixHours, twentyFourHours, sevenDays, thirtyDays }

class ETNotifier extends StateNotifier<ETState> {
  final RealtimeService _realtimeService;
  final ApiClient _apiClient;
  Timer? _pollTimer;

  static const int _maxTrendPoints = 500;

  ETNotifier(this._realtimeService, this._apiClient) : super(const ETState()) {
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchValues());
  }

  Future<void> _fetchValues() async {
    final allTags = [...state.inputTags, ...state.accumulationTags, ...state.reportTags];
    if (allTags.isEmpty) return;

    try {
      _realtimeService.subscribe(allTags);
      final now = DateTime.now();

      final updatedHistory = List<ETDataPoint>.from(state.etTrendData);

      final currentEToVal = _realtimeService.getValue(state.inputTags[4]);
      if (currentEToVal.isNotEmpty && currentEToVal != '--') {
        final parsed = double.tryParse(currentEToVal);
        if (parsed != null) {
          updatedHistory.add(ETDataPoint(timestamp: now, value: parsed));
          final cutoff = now.subtract(_timeRangeDuration(state.selectedTimeRange));
          final filtered = updatedHistory.where((p) => p.timestamp.isAfter(cutoff)).toList();
          if (filtered.length > _maxTrendPoints) {
            updatedHistory.removeRange(0, filtered.length - _maxTrendPoints);
          } else {
            updatedHistory.clear();
            updatedHistory.addAll(filtered);
          }
        }
      }

      state = state.copyWith(
        temperature: _realtimeService.getValue(state.inputTags[0]),
        humidity: _realtimeService.getValue(state.inputTags[1]),
        windSpeed: _realtimeService.getValue(state.inputTags[2]),
        solarRadiation: _realtimeService.getValue(state.inputTags[3]),
        currentETo: currentEToVal,
        calculatedETo: _realtimeService.getValue(state.inputTags[5]),
        dailyET: _realtimeService.getValue(state.accumulationTags[0]),
        weeklyET: _realtimeService.getValue(state.accumulationTags[1]),
        monthlyET: _realtimeService.getValue(state.accumulationTags[2]),
        yearlyET: _realtimeService.getValue(state.accumulationTags[3]),
        validETDays: _realtimeService.getValue(state.reportTags[0]),
        etAverage: _realtimeService.getValue(state.reportTags[1]),
        etLast7Days: _realtimeService.getValue(state.reportTags[2]),
        etLast30Days: _realtimeService.getValue(state.reportTags[3]),
        etTrendData: updatedHistory,
      );
    } catch (_) {}
  }

  Duration _timeRangeDuration(TimeRange range) {
    switch (range) {
      case TimeRange.oneHour:
        return const Duration(hours: 1);
      case TimeRange.sixHours:
        return const Duration(hours: 6);
      case TimeRange.twentyFourHours:
        return const Duration(hours: 24);
      case TimeRange.sevenDays:
        return const Duration(days: 7);
      case TimeRange.thirtyDays:
        return const Duration(days: 30);
    }
  }

  void setController(String controllerId) {
    state = state.copyWith(
      selectedController: controllerId,
      etTrendData: [],
    );
    _fetchValues();
  }

  void setTimeRange(TimeRange range) {
    state = state.copyWith(selectedTimeRange: range);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _realtimeService.unsubscribeAll();
    super.dispose();
  }
}

final etProvider = StateNotifierProvider<ETNotifier, ETState>((ref) {
  final realtimeService = ref.read(realtimeServiceProvider);
  final apiClient = ref.read(apiClientProvider);
  return ETNotifier(realtimeService, apiClient);
});
