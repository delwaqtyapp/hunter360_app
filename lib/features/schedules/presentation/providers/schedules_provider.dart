import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';

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
}

class ProgramBlock {
  final String id;
  final String name;
  final String runTime;
  final int stationNumber;

  const ProgramBlock({
    required this.id,
    required this.name,
    required this.runTime,
    required this.stationNumber,
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
        blocks.add(ProgramBlock(
          id: 'block_${programNum}_$i',
          name: 'Block $i',
          runTime: _formatMinutes(tagValues[runTimeKey] ?? 0),
          stationNumber: i,
        ));
      }
    }
    return blocks;
  }

  Future<void> toggleSchedule(String id) async {
    final currentSchedules = state.valueOrNull ?? [];
    final updatedSchedules = currentSchedules.map((schedule) {
      if (schedule.id == id) {
        return ScheduleEntity(
          id: schedule.id,
          name: schedule.name,
          controllerId: schedule.controllerId,
          enabled: !schedule.enabled,
          programNumber: schedule.programNumber,
          startTime: schedule.startTime,
          runTime: schedule.runTime,
          daysOfWeek: schedule.daysOfWeek,
          blocks: schedule.blocks,
        );
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
}

final schedulesProvider =
    StateNotifierProvider<SchedulesNotifier, AsyncValue<List<ScheduleEntity>>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SchedulesNotifier(apiClient);
});