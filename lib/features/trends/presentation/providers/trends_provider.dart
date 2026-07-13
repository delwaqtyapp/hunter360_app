import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';

class TrendDataPoint {
  final DateTime timestamp;
  final double value;

  const TrendDataPoint({required this.timestamp, required this.value});
}

enum TrendType { flow, currentDraw, seasonalAdjust }

enum TimeRange { oneHour, sixHours, twentyFourHours, sevenDays, thirtyDays }

class TrendsState {
  final String selectedController;
  final TrendType selectedTrendType;
  final TimeRange selectedTimeRange;
  final Map<String, List<TrendDataPoint>> tagHistories;
  final Map<String, String> currentValues;
  final double? minValue;
  final double? maxValue;
  final double? averageValue;
  final bool isLoading;

  const TrendsState({
    this.selectedController = 'C001',
    this.selectedTrendType = TrendType.flow,
    this.selectedTimeRange = TimeRange.twentyFourHours,
    this.tagHistories = const {},
    this.currentValues = const {},
    this.minValue,
    this.maxValue,
    this.averageValue,
    this.isLoading = false,
  });

  TrendsState copyWith({
    String? selectedController,
    TrendType? selectedTrendType,
    TimeRange? selectedTimeRange,
    Map<String, List<TrendDataPoint>>? tagHistories,
    Map<String, String>? currentValues,
    double? minValue,
    double? maxValue,
    double? averageValue,
    bool? isLoading,
  }) {
    return TrendsState(
      selectedController: selectedController ?? this.selectedController,
      selectedTrendType: selectedTrendType ?? this.selectedTrendType,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
      tagHistories: tagHistories ?? this.tagHistories,
      currentValues: currentValues ?? this.currentValues,
      minValue: minValue,
      maxValue: maxValue,
      averageValue: averageValue,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<String> get activeTags {
    switch (selectedTrendType) {
      case TrendType.flow:
        return [
          '$selectedController.FlowSensor1.FlowRate',
          '$selectedController.FlowSensor2.FlowRate',
        ];
      case TrendType.currentDraw:
        return [
          '$selectedController.CurrentDraw',
          '$selectedController.Module1.CurrentDraw',
        ];
      case TrendType.seasonalAdjust:
        return [
          '$selectedController.SeasonalAdjustment',
        ];
    }
  }

  Duration get timeRangeDuration {
    switch (selectedTimeRange) {
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
}

class TrendsNotifier extends StateNotifier<TrendsState> {
  final RealtimeService _realtimeService;
  final ApiClient _apiClient;
  Timer? _pollTimer;
  static const int _maxHistoryPoints = 500;

  TrendsNotifier(this._realtimeService, this._apiClient) : super(const TrendsState()) {
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchAndRecord());
  }

  Future<void> _fetchAndRecord() async {
    final tags = state.activeTags;
    if (tags.isEmpty) return;

    try {
      _realtimeService.subscribe(tags);
      final now = DateTime.now();
      final currentValues = <String, String>{};
      final updatedHistories = Map<String, List<TrendDataPoint>>.from(state.tagHistories);

      for (final tag in tags) {
        final value = _realtimeService.getValue(tag);
        currentValues[tag] = value;
        final parsedValue = double.tryParse(value);
        if (parsedValue != null) {
          final history = List<TrendDataPoint>.from(updatedHistories[tag] ?? []);
          history.add(TrendDataPoint(timestamp: now, value: parsedValue));
          final cutoff = now.subtract(state.timeRangeDuration);
          final filtered = history.where((p) => p.timestamp.isAfter(cutoff)).toList();
          if (filtered.length > _maxHistoryPoints) {
            updatedHistories[tag] = filtered.sublist(filtered.length - _maxHistoryPoints);
          } else {
            updatedHistories[tag] = filtered;
          }
        }
      }

      double? minVal;
      double? maxVal;
      double sum = 0;
      int count = 0;
      for (final tag in tags) {
        final points = updatedHistories[tag] ?? [];
        for (final p in points) {
          if (minVal == null || p.value < minVal) minVal = p.value;
          if (maxVal == null || p.value > maxVal) maxVal = p.value;
          sum += p.value;
          count++;
        }
      }

      state = state.copyWith(
        tagHistories: updatedHistories,
        currentValues: currentValues,
        minValue: minVal,
        maxValue: maxVal,
        averageValue: count > 0 ? sum / count : null,
      );
    } catch (_) {}
  }

  void setController(String controllerId) {
    state = state.copyWith(
      selectedController: controllerId,
      tagHistories: {},
      currentValues: {},
      minValue: null,
      maxValue: null,
      averageValue: null,
    );
    _fetchAndRecord();
  }

  void setTrendType(TrendType type) {
    state = state.copyWith(
      selectedTrendType: type,
      tagHistories: {},
      currentValues: {},
      minValue: null,
      maxValue: null,
      averageValue: null,
    );
    _fetchAndRecord();
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

final trendsProvider = StateNotifierProvider<TrendsNotifier, TrendsState>((ref) {
  final realtimeService = ref.read(realtimeServiceProvider);
  final apiClient = ref.read(apiClientProvider);
  return TrendsNotifier(realtimeService, apiClient);
});
