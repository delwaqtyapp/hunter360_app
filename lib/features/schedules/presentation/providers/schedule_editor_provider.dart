import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';

class StationRunTime {
  final String stationId;
  final String stationName;
  final int stationNumber;
  final int runTimeMinutes;
  final bool enabled;

  const StationRunTime({
    required this.stationId,
    required this.stationName,
    required this.stationNumber,
    this.runTimeMinutes = 0,
    this.enabled = false,
  });

  StationRunTime copyWith({int? runTimeMinutes, bool? enabled}) {
    return StationRunTime(
      stationId: stationId,
      stationName: stationName,
      stationNumber: stationNumber,
      runTimeMinutes: runTimeMinutes ?? this.runTimeMinutes,
      enabled: enabled ?? this.enabled,
    );
  }
}

enum ScheduleType { weekly, oddEven, interval }

class ScheduleEditorState {
  final String controllerId;
  final int selectedProgram;
  final List<bool> selectedDays;
  final List<TimeOfDay> startTimes;
  final List<StationRunTime> stations;
  final ScheduleType scheduleType;
  final TimeOfDay? noWaterStart;
  final TimeOfDay? noWaterEnd;
  final int seasonalAdjustment;
  final bool isSaving;
  final String? error;

  const ScheduleEditorState({
    this.controllerId = 'C001',
    this.selectedProgram = 0,
    this.selectedDays = const [false, false, false, false, false, false, false],
    this.startTimes = const [],
    this.stations = const [],
    this.scheduleType = ScheduleType.weekly,
    this.noWaterStart,
    this.noWaterEnd,
    this.seasonalAdjustment = 100,
    this.isSaving = false,
    this.error,
  });

  ScheduleEditorState copyWith({
    String? controllerId,
    int? selectedProgram,
    List<bool>? selectedDays,
    List<TimeOfDay>? startTimes,
    List<StationRunTime>? stations,
    ScheduleType? scheduleType,
    TimeOfDay? noWaterStart,
    bool clearNoWaterStart = false,
    TimeOfDay? noWaterEnd,
    bool clearNoWaterEnd = false,
    int? seasonalAdjustment,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return ScheduleEditorState(
      controllerId: controllerId ?? this.controllerId,
      selectedProgram: selectedProgram ?? this.selectedProgram,
      selectedDays: selectedDays ?? this.selectedDays,
      startTimes: startTimes ?? this.startTimes,
      stations: stations ?? this.stations,
      scheduleType: scheduleType ?? this.scheduleType,
      noWaterStart: clearNoWaterStart ? null : (noWaterStart ?? this.noWaterStart),
      noWaterEnd: clearNoWaterEnd ? null : (noWaterEnd ?? this.noWaterEnd),
      seasonalAdjustment: seasonalAdjustment ?? this.seasonalAdjustment,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ScheduleEditorNotifier extends StateNotifier<ScheduleEditorState> {
  final ApiClient _apiClient;

  ScheduleEditorNotifier(this._apiClient) : super(const ScheduleEditorState());

  void setController(String controllerId) {
    state = state.copyWith(controllerId: controllerId);
  }

  void setProgram(int program) {
    state = state.copyWith(selectedProgram: program);
  }

  void toggleDay(int index) {
    final days = List<bool>.from(state.selectedDays);
    if (index >= 0 && index < days.length) {
      days[index] = !days[index];
      state = state.copyWith(selectedDays: days);
    }
  }

  void addStartTime(TimeOfDay time) {
    if (state.startTimes.length < 10) {
      final times = List<TimeOfDay>.from(state.startTimes)..add(time);
      times.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      state = state.copyWith(startTimes: times);
    }
  }

  void removeStartTime(int index) {
    final times = List<TimeOfDay>.from(state.startTimes);
    if (index >= 0 && index < times.length) {
      times.removeAt(index);
      state = state.copyWith(startTimes: times);
    }
  }

  void loadStations(List<StationRunTime> stations) {
    state = state.copyWith(stations: stations);
  }

  void updateStationRunTime(int index, int minutes) {
    final stations = List<StationRunTime>.from(state.stations);
    if (index >= 0 && index < stations.length) {
      stations[index] = stations[index].copyWith(runTimeMinutes: minutes);
      state = state.copyWith(stations: stations);
    }
  }

  void toggleStation(int index) {
    final stations = List<StationRunTime>.from(state.stations);
    if (index >= 0 && index < stations.length) {
      stations[index] = stations[index].copyWith(enabled: !stations[index].enabled);
      state = state.copyWith(stations: stations);
    }
  }

  void setScheduleType(ScheduleType type) {
    state = state.copyWith(scheduleType: type);
  }

  void setNoWaterStart(TimeOfDay time) {
    state = state.copyWith(noWaterStart: time);
  }

  void setNoWaterEnd(TimeOfDay time) {
    state = state.copyWith(noWaterEnd: time);
  }

  void clearNoWaterStart() {
    state = state.copyWith(clearNoWaterStart: true);
  }

  void clearNoWaterEnd() {
    state = state.copyWith(clearNoWaterEnd: true);
  }

  void setSeasonalAdjustment(int value) {
    state = state.copyWith(seasonalAdjustment: value);
  }

  int _daysToBitmask() {
    int mask = 0;
    for (int i = 0; i < state.selectedDays.length; i++) {
      if (state.selectedDays[i]) {
        mask |= (1 << i);
      }
    }
    return mask;
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> saveSchedule() async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final programLetter = String.fromCharCode(65 + state.selectedProgram);
      final prefix = '${state.controllerId}.Program$programLetter';

      final writeTasks = <Future>[];

      writeTasks.add(_apiClient.post(ApiConstants.tagsWrite, data: {
        'tagName': '$prefix.Enabled',
        'value': true,
      }));

      writeTasks.add(_apiClient.post(ApiConstants.tagsWrite, data: {
        'tagName': '$prefix.DaysOfWeek',
        'value': _daysToBitmask(),
      }));

      for (int i = 0; i < state.startTimes.length && i < 10; i++) {
        final minutes = state.startTimes[i].hour * 60 + state.startTimes[i].minute;
        writeTasks.add(_apiClient.post(ApiConstants.tagsWrite, data: {
          'tagName': '$prefix.StartTime${i + 1}',
          'value': minutes,
        }));
      }

      for (final station in state.stations) {
        final tag = '$prefix.Station${station.stationNumber}.RunTime';
        writeTasks.add(_apiClient.post(ApiConstants.tagsWrite, data: {
          'tagName': tag,
          'value': station.enabled ? station.runTimeMinutes : 0,
        }));
      }

      if (state.noWaterStart != null && state.noWaterEnd != null) {
        final startMinutes = state.noWaterStart!.hour * 60 + state.noWaterStart!.minute;
        final endMinutes = state.noWaterEnd!.hour * 60 + state.noWaterEnd!.minute;
        writeTasks.add(_apiClient.post(ApiConstants.tagsWrite, data: {
          'tagName': '$prefix.NoWaterStart',
          'value': startMinutes,
        }));
        writeTasks.add(_apiClient.post(ApiConstants.tagsWrite, data: {
          'tagName': '$prefix.NoWaterEnd',
          'value': endMinutes,
        }));
      }

      await Future.wait(writeTasks);
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }
}

final scheduleEditorProvider =
    StateNotifierProvider<ScheduleEditorNotifier, ScheduleEditorState>((ref) {
  return ScheduleEditorNotifier(ref.read(apiClientProvider));
});
