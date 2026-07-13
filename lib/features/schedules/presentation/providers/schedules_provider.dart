import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';

enum ScheduleType { weekly, oddEven, interval, manual }

enum OddEvenMode { odd, even, both }

enum StackOverlapMode { stack, overlap }

class NoWaterWindow {
  final String startTime;
  final String endTime;
  final bool enabled;

  const NoWaterWindow({
    this.startTime = '00:00',
    this.endTime = '00:00',
    this.enabled = false,
  });

  NoWaterWindow copyWith({String? startTime, String? endTime, bool? enabled}) {
    return NoWaterWindow(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      enabled: enabled ?? this.enabled,
    );
  }
}

class StartTimeEntry {
  final int index;
  final String time;
  final bool enabled;

  const StartTimeEntry({
    required this.index,
    this.time = '06:00 AM',
    this.enabled = false,
  });

  StartTimeEntry copyWith({String? time, bool? enabled}) {
    return StartTimeEntry(
      index: index,
      time: time ?? this.time,
      enabled: enabled ?? this.enabled,
    );
  }
}

class ScheduleEntity {
  final String id;
  final String name;
  final String controllerId;
  final bool enabled;
  final int programNumber;
  final String startTime;
  final String runTime;
  final List<bool> daysOfWeek;
  final List<ProgramBlock> blocks;
  final ScheduleType scheduleType;
  final OddEvenMode oddEvenMode;
  final int intervalDays;
  final NoWaterWindow noWaterWindow;
  final String stationDelay;
  final StackOverlapMode stackOverlapMode;
  final List<StartTimeEntry> startTimes;
  final bool programAutoMode;

  const ScheduleEntity({
    required this.id,
    required this.name,
    required this.controllerId,
    required this.enabled,
    required this.programNumber,
    required this.startTime,
    required this.runTime,
    required this.daysOfWeek,
    required this.blocks,
    this.scheduleType = ScheduleType.weekly,
    this.oddEvenMode = OddEvenMode.odd,
    this.intervalDays = 1,
    this.noWaterWindow = const NoWaterWindow(),
    this.stationDelay = '00:00:30',
    this.stackOverlapMode = StackOverlapMode.stack,
    this.startTimes = const [],
    this.programAutoMode = true,
  });

  factory ScheduleEntity.fromJson(Map<String, dynamic> json) {
    return ScheduleEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      controllerId: json['controllerId'] as String,
      enabled: json['enabled'] as bool,
      programNumber: json['programNumber'] as int,
      startTime: json['startTime'] as String,
      runTime: json['runTime'] as String,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>).map((e) => e as bool).toList(),
      blocks: (json['blocks'] as List<dynamic>)
          .map((e) => ProgramBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'controllerId': controllerId,
      'enabled': enabled,
      'programNumber': programNumber,
      'startTime': startTime,
      'runTime': runTime,
      'daysOfWeek': daysOfWeek,
      'blocks': blocks.map((e) => e.toJson()).toList(),
    };
  }

  ScheduleEntity copyWith({
    String? name,
    bool? enabled,
    String? startTime,
    String? runTime,
    List<bool>? daysOfWeek,
    List<ProgramBlock>? blocks,
    ScheduleType? scheduleType,
    OddEvenMode? oddEvenMode,
    int? intervalDays,
    NoWaterWindow? noWaterWindow,
    String? stationDelay,
    StackOverlapMode? stackOverlapMode,
    List<StartTimeEntry>? startTimes,
    bool? programAutoMode,
  }) {
    return ScheduleEntity(
      id: id,
      name: name ?? this.name,
      controllerId: controllerId,
      enabled: enabled ?? this.enabled,
      programNumber: programNumber,
      startTime: startTime ?? this.startTime,
      runTime: runTime ?? this.runTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      blocks: blocks ?? this.blocks,
      scheduleType: scheduleType ?? this.scheduleType,
      oddEvenMode: oddEvenMode ?? this.oddEvenMode,
      intervalDays: intervalDays ?? this.intervalDays,
      noWaterWindow: noWaterWindow ?? this.noWaterWindow,
      stationDelay: stationDelay ?? this.stationDelay,
      stackOverlapMode: stackOverlapMode ?? this.stackOverlapMode,
      startTimes: startTimes ?? this.startTimes,
      programAutoMode: programAutoMode ?? this.programAutoMode,
    );
  }
}

class ProgramBlock {
  final String id;
  final String name;
  final String runTime;
  final int stationNumber;
  final int runTimeMinutes;
  final double seasonalAdjustedMinutes;

  const ProgramBlock({
    required this.id,
    required this.name,
    required this.runTime,
    required this.stationNumber,
    this.runTimeMinutes = 0,
    this.seasonalAdjustedMinutes = 0,
  });

  factory ProgramBlock.fromJson(Map<String, dynamic> json) {
    return ProgramBlock(
      id: json['id'] as String,
      name: json['name'] as String,
      runTime: json['runTime'] as String,
      stationNumber: json['stationNumber'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'runTime': runTime,
      'stationNumber': stationNumber,
    };
  }

  ProgramBlock copyWith({
    String? name,
    String? runTime,
    int? runTimeMinutes,
    double? seasonalAdjustedMinutes,
  }) {
    return ProgramBlock(
      id: id,
      name: name ?? this.name,
      runTime: runTime ?? this.runTime,
      stationNumber: stationNumber,
      runTimeMinutes: runTimeMinutes ?? this.runTimeMinutes,
      seasonalAdjustedMinutes: seasonalAdjustedMinutes ?? this.seasonalAdjustedMinutes,
    );
  }
}

class SchedulesState {
  final List<ScheduleEntity> schedules;
  final bool isLoading;
  final String? error;

  const SchedulesState({
    this.schedules = const [],
    this.isLoading = false,
    this.error,
  });

  SchedulesState copyWith({
    List<ScheduleEntity>? schedules,
    bool? isLoading,
    String? error,
  }) {
    return SchedulesState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SchedulesNotifier extends StateNotifier<AsyncValue<List<ScheduleEntity>>> {
  final ApiClient _apiClient;

  SchedulesNotifier(this._apiClient) : super(const AsyncValue.loading()) {
    loadSchedules('');
  }

  Future<void> loadSchedules(String controllerId) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiClient.get(ApiConstants.tagsList);
      final tags = response.data as List<dynamic>;
      final programs = _filterProgramTags(tags, controllerId);
      state = AsyncValue.data(programs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<ScheduleEntity> _filterProgramTags(List<dynamic> tags, String controllerId) {
    final programTags = tags.where((tag) {
      final name = tag['name'] as String? ?? '';
      return name.contains('Program') && name.contains(controllerId);
    }).toList();

    final Map<int, Map<String, dynamic>> programMap = {};

    for (final tag in programTags) {
      final name = tag['name'] as String;
      final value = tag['value'];
      final programNum = _extractProgramNumber(name);

      if (programNum != null) {
        if (!programMap.containsKey(programNum)) {
          programMap[programNum] = {};
        }
        programMap[programNum]![name] = value;
      }
    }

    final schedules = <ScheduleEntity>[];
    programMap.forEach((programNum, tagValues) {
      final enabled = tagValues['Enabled'] == true || tagValues['Enabled'] == 1;
      final startTime = _formatTime(tagValues['StartTime'] ?? 0);
      final runTime = _formatMinutes(tagValues['RunTime'] ?? 0);
      final daysOfWeek = _parseDaysOfWeek(tagValues['DaysOfWeek'] ?? 0);
      final blocks = _parseBlocks(tagValues, programNum);

      final startTimes = List.generate(10, (i) {
        return StartTimeEntry(
          index: i + 1,
          time: i == 0 ? startTime : '06:00 AM',
          enabled: i == 0,
        );
      });

      schedules.add(ScheduleEntity(
        id: 'program_$controllerId\_$programNum',
        name: 'Program $programNum',
        controllerId: controllerId,
        enabled: enabled,
        programNumber: programNum,
        startTime: startTime,
        runTime: runTime,
        daysOfWeek: daysOfWeek,
        blocks: blocks,
        startTimes: startTimes,
      ));
    });

    schedules.sort((a, b) => a.programNumber.compareTo(b.programNumber));
    return schedules;
  }

  int? _extractProgramNumber(String tagName) {
    final regex = RegExp(r'Program(\d+)');
    final match = regex.firstMatch(tagName);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  String _formatTime(dynamic timeValue) {
    final minutes = timeValue is int ? timeValue : int.tryParse(timeValue.toString()) ?? 0;
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final period = hours >= 12 ? 'PM' : 'AM';
    final displayHours = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours);
    return '${displayHours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')} $period';
  }

  String _formatMinutes(dynamic timeValue) {
    final minutes = timeValue is int ? timeValue : int.tryParse(timeValue.toString()) ?? 0;
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  List<bool> _parseDaysOfWeek(dynamic daysValue) {
    final days = daysValue is int ? daysValue : int.tryParse(daysValue.toString()) ?? 0;
    return List.generate(7, (index) {
      return (days & (1 << index)) != 0;
    });
  }

  List<ProgramBlock> _parseBlocks(Map<String, dynamic> tagValues, int programNum) {
    final blocks = <ProgramBlock>[];
    for (int i = 1; i <= 8; i++) {
      final blockKey = 'Program$programNum.Block$i';
      final runTimeKey = 'Program$programNum.Block${i}RunTime';

      if (tagValues.containsKey(blockKey)) {
        final rawMinutes = tagValues[runTimeKey] is int
            ? tagValues[runTimeKey] as int
            : int.tryParse(tagValues[runTimeKey].toString()) ?? 0;
        blocks.add(ProgramBlock(
          id: 'block_${programNum}_$i',
          name: 'Block $i',
          runTime: _formatMinutes(tagValues[runTimeKey] ?? 0),
          stationNumber: i,
          runTimeMinutes: rawMinutes,
          seasonalAdjustedMinutes: rawMinutes.toDouble(),
        ));
      }
    }
    return blocks;
  }

  Future<void> toggleSchedule(String id) async {
    final currentSchedules = state.valueOrNull ?? [];
    final updatedSchedules = currentSchedules.map((schedule) {
      if (schedule.id == id) {
        return schedule.copyWith(enabled: !schedule.enabled);
      }
      return schedule;
    }).toList();

    state = AsyncValue.data(updatedSchedules);

    try {
      final schedule = currentSchedules.firstWhere((s) => s.id == id);
      final tagName = '${schedule.controllerId}.Program${schedule.programNumber}.Enabled';
      await _apiClient.post(ApiConstants.tagsWrite, data: {
        'tagName': tagName,
        'value': schedule.enabled ? 0 : 1,
      });
    } catch (e) {
      state = AsyncValue.data(currentSchedules);
    }
  }

  Future<void> updateSeasonalAdjustment(String controllerId, double value) async {
    try {
      final tagName = '$controllerId.SeasonalAdjustment';
      await _apiClient.post(ApiConstants.tagsWrite, data: {
        'tagName': tagName,
        'value': value.toInt(),
      });
    } catch (e) {
      rethrow;
    }
  }

  void updateScheduleType(String id, ScheduleType type) {
    _updateSchedule(id, (s) => s.copyWith(scheduleType: type));
  }

  void updateOddEvenMode(String id, OddEvenMode mode) {
    _updateSchedule(id, (s) => s.copyWith(oddEvenMode: mode));
  }

  void updateIntervalDays(String id, int days) {
    _updateSchedule(id, (s) => s.copyWith(intervalDays: days));
  }

  void updateNoWaterWindow(String id, NoWaterWindow window) {
    _updateSchedule(id, (s) => s.copyWith(noWaterWindow: window));
  }

  void updateStationDelay(String id, String delay) {
    _updateSchedule(id, (s) => s.copyWith(stationDelay: delay));
  }

  void updateStackOverlapMode(String id, StackOverlapMode mode) {
    _updateSchedule(id, (s) => s.copyWith(stackOverlapMode: mode));
  }

  void updateStartTime(String id, int index, String time) {
    _updateSchedule(id, (s) {
      final updatedTimes = s.startTimes.map((e) {
        if (e.index == index) return e.copyWith(time: time);
        return e;
      }).toList();
      return s.copyWith(startTimes: updatedTimes);
    });
  }

  void toggleStartTime(String id, int index) {
    _updateSchedule(id, (s) {
      final updatedTimes = s.startTimes.map((e) {
        if (e.index == index) return e.copyWith(enabled: !e.enabled);
        return e;
      }).toList();
      return s.copyWith(startTimes: updatedTimes);
    });
  }

  void updateBlockRunTime(String scheduleId, String blockId, int minutes) {
    _updateSchedule(scheduleId, (s) {
      final updatedBlocks = s.blocks.map((b) {
        if (b.id == blockId) {
          final hours = minutes ~/ 60;
          final mins = minutes % 60;
          final formatted = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
          return b.copyWith(
            runTime: formatted,
            runTimeMinutes: minutes,
            seasonalAdjustedMinutes: minutes.toDouble(),
          );
        }
        return b;
      }).toList();
      return s.copyWith(blocks: updatedBlocks);
    });
  }

  void updateBlockSeasonalAdjusted(String scheduleId, String blockId, double seasonalPercent) {
    _updateSchedule(scheduleId, (s) {
      final updatedBlocks = s.blocks.map((b) {
        if (b.id == blockId) {
          final adjusted = b.runTimeMinutes * (seasonalPercent / 100);
          return b.copyWith(seasonalAdjustedMinutes: adjusted);
        }
        return b;
      }).toList();
      return s.copyWith(blocks: updatedBlocks);
    });
  }

  void toggleProgramMode(String id) {
    _updateSchedule(id, (s) => s.copyWith(programAutoMode: !s.programAutoMode));
  }

  void toggleDayOfWeek(String id, int dayIndex) {
    _updateSchedule(id, (s) {
      final updated = List<bool>.from(s.daysOfWeek);
      if (dayIndex < updated.length) {
        updated[dayIndex] = !updated[dayIndex];
      }
      return s.copyWith(daysOfWeek: updated);
    });
  }

  void _updateSchedule(String id, ScheduleEntity Function(ScheduleEntity) updater) {
    final currentSchedules = state.valueOrNull ?? [];
    final updatedSchedules = currentSchedules.map((s) {
      if (s.id == id) return updater(s);
      return s;
    }).toList();
    state = AsyncValue.data(updatedSchedules);
  }
}

final schedulesProvider =
    StateNotifierProvider<SchedulesNotifier, AsyncValue<List<ScheduleEntity>>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SchedulesNotifier(apiClient);
});
