import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/utils/response_parser.dart';

class HistoricalAlarm {
  final String id;
  final String alarmTime;
  final String tagName;
  final String tagGroup;
  final String state;
  final String alarmType;
  final int priority;
  final String ack;
  final String alarmComment;
  final String userDef3;
  final String? ackTime;

  const HistoricalAlarm({
    required this.id,
    this.alarmTime = '',
    this.tagName = '',
    this.tagGroup = '',
    this.state = '',
    this.alarmType = '',
    this.priority = 1,
    this.ack = '',
    this.alarmComment = '',
    this.userDef3 = '',
    this.ackTime,
  });

  bool get isAcknowledged => ack.toLowerCase() == 'acked';
  bool get isCritical => priority >= 4;
  bool get isWarning => priority >= 2 && priority < 4;
  bool get isInfo => priority == 1;

  Color get priorityColor {
    if (priority <= 1) return const Color(0xFF2196F3);
    if (priority == 2) return const Color(0xFFFF9800);
    if (priority == 3) return const Color(0xFFFF6D00);
    return const Color(0xFFF44336);
  }

  factory HistoricalAlarm.fromJson(Map<String, dynamic> json) {
    return HistoricalAlarm(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      alarmTime: json['AlarmTime']?.toString() ?? '',
      tagName: json['TagName']?.toString() ?? '',
      tagGroup: json['TagGroup']?.toString() ?? '',
      state: json['State']?.toString() ?? '',
      alarmType: json['AlarmType']?.toString() ?? '',
      priority: json['Priority'] is int
          ? json['Priority']
          : int.tryParse(json['Priority']?.toString() ?? '1') ?? 1,
      ack: json['Ack']?.toString() ?? '',
      alarmComment: json['AlarmComment']?.toString() ?? '',
      userDef3: json['User_Def_3']?.toString() ?? '',
      ackTime: json['AckTime']?.toString(),
    );
  }
}

enum HistoryPriorityFilter { all, critical, warning, info }

class AlarmHistoryState {
  final List<HistoricalAlarm> alarms;
  final DateTime? startDate;
  final DateTime? endDate;
  final String controllerFilter;
  final HistoryPriorityFilter priorityFilter;
  final bool isLoading;
  final String? error;

  const AlarmHistoryState({
    this.alarms = const [],
    this.startDate,
    this.endDate,
    this.controllerFilter = '',
    this.priorityFilter = HistoryPriorityFilter.all,
    this.isLoading = false,
    this.error,
  });

  AlarmHistoryState copyWith({
    List<HistoricalAlarm>? alarms,
    DateTime? startDate,
    DateTime? endDate,
    String? controllerFilter,
    HistoryPriorityFilter? priorityFilter,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AlarmHistoryState(
      alarms: alarms ?? this.alarms,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      controllerFilter: controllerFilter ?? this.controllerFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<HistoricalAlarm> get filteredAlarms {
    List<HistoricalAlarm> result = List.from(alarms);

    if (priorityFilter != HistoryPriorityFilter.all) {
      switch (priorityFilter) {
        case HistoryPriorityFilter.critical:
          result = result.where((a) => a.isCritical).toList();
          break;
        case HistoryPriorityFilter.warning:
          result = result.where((a) => a.isWarning).toList();
          break;
        case HistoryPriorityFilter.info:
          result = result.where((a) => a.isInfo).toList();
          break;
        case HistoryPriorityFilter.all:
          break;
      }
    }

    if (controllerFilter.isNotEmpty) {
      result = result.where((a) => a.tagGroup == controllerFilter).toList();
    }

    return result;
  }

  int get totalCount => alarms.length;
  int get criticalCount => alarms.where((a) => a.isCritical).length;
  int get warningCount => alarms.where((a) => a.isWarning).length;
  int get infoCount => alarms.where((a) => a.isInfo).length;

  String get mostCommonAlarmType {
    if (alarms.isEmpty) return '-';
    final Map<String, int> counts = {};
    for (final a in alarms) {
      final type = a.alarmType.isNotEmpty ? a.alarmType : 'Unknown';
      counts[type] = (counts[type] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }
}

class AlarmHistoryNotifier extends StateNotifier<AlarmHistoryState> {
  final ApiClient _apiClient;

  AlarmHistoryNotifier(this._apiClient) : super(const AlarmHistoryState());

  Future<void> loadAlarms() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{
        'TagFilter': state.controllerFilter.isNotEmpty ? state.controllerFilter : '*',
        'PriFrom': '1',
        'PriTo': '6',
      };
      if (state.startDate != null) {
        queryParams['StartDate'] = state.startDate!.toIso8601String().substring(0, 19);
      }
      if (state.endDate != null) {
        queryParams['EndDate'] = state.endDate!.toIso8601String().substring(0, 19);
      }

      final response = await _apiClient.get(
        ApiConstants.historicalAlarms,
        queryParameters: queryParams,
      );
      final alarms = ResponseParser.parseAlarmsList(response.data)
          .map((json) => HistoricalAlarm.fromJson(json))
          .toList();
      state = state.copyWith(alarms: alarms, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void setControllerFilter(String controllerId) {
    state = state.copyWith(controllerFilter: controllerId);
  }

  void setPriorityFilter(HistoryPriorityFilter filter) {
    state = state.copyWith(priorityFilter: filter);
  }
}

final alarmHistoryProvider = StateNotifierProvider<AlarmHistoryNotifier, AlarmHistoryState>((ref) {
  return AlarmHistoryNotifier(ref.read(apiClientProvider));
});
