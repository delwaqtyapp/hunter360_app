import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/utils/response_parser.dart';

class AlarmEntity {
  final String id;
  final String alarmTime;
  final String tagName;
  final String tagGroup;
  final String state;
  final String alarmType;
  final String tagValue;
  final int priority;
  final String ack;
  final String alarmComment;
  final String userDef3;

  const AlarmEntity({
    required this.id,
    this.alarmTime = '',
    this.tagName = '',
    this.tagGroup = '',
    this.state = '',
    this.alarmType = '',
    this.tagValue = '',
    this.priority = 1,
    this.ack = '',
    this.alarmComment = '',
    this.userDef3 = '',
  });

  bool get isAcknowledged => ack.toLowerCase() == 'acked';
  bool get isCritical => priority >= 4;
  bool get isWarning => priority >= 2 && priority < 4;
  bool get isInfo => priority == 1;

  factory AlarmEntity.fromJson(Map<String, dynamic> json) {
    return AlarmEntity(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      alarmTime: json['AlarmTime']?.toString() ?? '',
      tagName: json['TagName']?.toString() ?? '',
      tagGroup: json['TagGroup']?.toString() ?? '',
      state: json['State']?.toString() ?? '',
      alarmType: json['AlarmType']?.toString() ?? '',
      tagValue: json['TagValue']?.toString() ?? '',
      priority: json['Priority'] is int
          ? json['Priority']
          : int.tryParse(json['Priority']?.toString() ?? '1') ?? 1,
      ack: json['Ack']?.toString() ?? '',
      alarmComment: json['AlarmComment']?.toString() ?? '',
      userDef3: json['User_Def_3']?.toString() ?? '',
    );
  }

  AlarmEntity copyWith({String? ack}) {
    return AlarmEntity(
      id: id,
      alarmTime: alarmTime,
      tagName: tagName,
      tagGroup: tagGroup,
      state: state,
      alarmType: alarmType,
      tagValue: tagValue,
      priority: priority,
      ack: ack ?? this.ack,
      alarmComment: alarmComment,
      userDef3: userDef3,
    );
  }
}

enum AlarmFilterType { all, critical, warning, info }

class AlarmsState {
  final List<AlarmEntity> alarms;
  final AlarmFilterType filterType;
  final String controllerFilter;
  final String searchText;
  final bool isLoading;
  final String? error;

  const AlarmsState({
    this.alarms = const [],
    this.filterType = AlarmFilterType.all,
    this.controllerFilter = '',
    this.searchText = '',
    this.isLoading = false,
    this.error,
  });

  List<AlarmEntity> get filteredAlarms {
    List<AlarmEntity> result = List.from(alarms);

    if (filterType != AlarmFilterType.all) {
      switch (filterType) {
        case AlarmFilterType.critical:
          result = result.where((a) => a.isCritical).toList();
          break;
        case AlarmFilterType.warning:
          result = result.where((a) => a.isWarning).toList();
          break;
        case AlarmFilterType.info:
          result = result.where((a) => a.isInfo).toList();
          break;
        case AlarmFilterType.all:
          break;
      }
    }

    if (controllerFilter.isNotEmpty) {
      result = result.where((a) => a.tagGroup == controllerFilter).toList();
    }

    if (searchText.isNotEmpty) {
      final query = searchText.toLowerCase();
      result = result.where((a) {
        return a.alarmComment.toLowerCase().contains(query) ||
            a.tagName.toLowerCase().contains(query) ||
            a.tagGroup.toLowerCase().contains(query) ||
            a.userDef3.toLowerCase().contains(query) ||
            a.alarmType.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  int get totalCount => alarms.length;
  int get activeCount => alarms.where((a) => !a.isAcknowledged).length;
  int get criticalCount => alarms.where((a) => a.isCritical).length;
  int get warningCount => alarms.where((a) => a.isWarning).length;
  int get infoCount => alarms.where((a) => a.isInfo).length;
  int get ackedCount => alarms.where((a) => a.isAcknowledged).length;

  int get filteredCriticalCount => filteredAlarms.where((a) => a.isCritical).length;
  int get filteredWarningCount => filteredAlarms.where((a) => a.isWarning).length;
  int get filteredInfoCount => filteredAlarms.where((a) => a.isInfo).length;
}

class AlarmsNotifier extends StateNotifier<AlarmsState> {
  final ApiClient _apiClient;

  AlarmsNotifier(this._apiClient) : super(const AlarmsState());

  Future<void> loadAlarms() async {
    state = AlarmsState(
      isLoading: true,
      filterType: state.filterType,
      controllerFilter: state.controllerFilter,
      searchText: state.searchText,
    );
    try {
      final response = await _apiClient.get(ApiConstants.alarmsCurrent);
      final alarms = ResponseParser.parseAlarmsList(response.data)
          .map((json) => AlarmEntity.fromJson(json))
          .toList();
      state = AlarmsState(
        alarms: alarms,
        filterType: state.filterType,
        controllerFilter: state.controllerFilter,
        searchText: state.searchText,
      );
    } catch (e) {
      state = AlarmsState(
        error: e.toString(),
        filterType: state.filterType,
        controllerFilter: state.controllerFilter,
        searchText: state.searchText,
      );
    }
  }

  void setFilterType(AlarmFilterType type) {
    state = AlarmsState(
      alarms: state.alarms,
      filterType: type,
      controllerFilter: state.controllerFilter,
      searchText: state.searchText,
    );
  }

  void setControllerFilter(String controllerId) {
    state = AlarmsState(
      alarms: state.alarms,
      filterType: state.filterType,
      controllerFilter: controllerId,
      searchText: state.searchText,
    );
  }

  void setSearchText(String text) {
    state = AlarmsState(
      alarms: state.alarms,
      filterType: state.filterType,
      controllerFilter: state.controllerFilter,
      searchText: text,
    );
  }

  Future<void> acknowledgeAlarm(String id) async {
    try {
      await _apiClient.get(ApiConstants.alarmAck(id));
      state = AlarmsState(
        alarms: state.alarms
            .map((a) => a.id == id ? a.copyWith(ack: 'Acked') : a)
            .toList(),
        filterType: state.filterType,
        controllerFilter: state.controllerFilter,
        searchText: state.searchText,
      );
    } catch (_) {}
  }
}

final alarmsProvider = StateNotifierProvider<AlarmsNotifier, AlarmsState>((ref) {
  return AlarmsNotifier(ref.read(apiClientProvider));
});
