import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/features/alarms/domain/entities/alarm.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';

class AlarmsState {
  final List<Alarm> alarms;
  final String filter;
  final bool isLoading;
  final String? error;

  const AlarmsState({this.alarms = const [], this.filter = 'all', this.isLoading = false, this.error});

  List<Alarm> get filteredAlarms {
    if (filter == 'all') return alarms;
    if (filter == 'active') return alarms.where((a) => !a.acknowledged).toList();
    return alarms.where((a) => !a.acknowledged && a.severity.toLowerCase() == filter).toList();
  }

  int get activeCount => alarms.where((a) => !a.acknowledged).length;
  int get criticalCount => alarms.where((a) => a.severity == 'critical').length;
  int get warningCount => alarms.where((a) => a.severity == 'warning').length;
}

class AlarmsNotifier extends StateNotifier<AlarmsState> {
  final ApiClient _apiClient;

  AlarmsNotifier(this._apiClient) : super(const AlarmsState());

  Future<void> loadAlarms() async {
    state = AlarmsState(isLoading: true, filter: state.filter);
    try {
      final response = await _apiClient.get(ApiConstants.alarmsCurrent);
      final data = response.data;
      final List<dynamic> alarmsList;
      if (data is Map) {
        alarmsList = data['Alarms'] ?? data['Data'] ?? [];
      } else if (data is List) {
        alarmsList = data;
      } else {
        alarmsList = [];
      }
      final alarms = alarmsList.map((json) => Alarm.fromJson(json as Map<String, dynamic>)).toList();
      state = AlarmsState(alarms: alarms, filter: state.filter);
    } catch (e) {
      state = AlarmsState(error: e.toString(), filter: state.filter);
    }
  }

  void setFilter(String filter) {
    state = AlarmsState(alarms: state.alarms, filter: filter);
  }

  Future<void> acknowledgeAlarm(String id) async {
    try {
      await _apiClient.get(ApiConstants.alarmAck(id));
      state = AlarmsState(
        alarms: state.alarms.map((a) => a.id == id
            ? Alarm(
                id: a.id,
                controllerId: a.controllerId,
                controllerName: a.controllerName,
                type: a.type,
                severity: a.severity,
                message: a.message,
                timestamp: a.timestamp,
                acknowledged: true,
                priority: a.priority,
                alarmType: a.alarmType,
                tagValue: a.tagValue,
                state: a.state,
                userDef3: a.userDef3,
              )
            : a).toList(),
        filter: state.filter,
      );
    } catch (_) {}
  }
}

final alarmsProvider = StateNotifierProvider<AlarmsNotifier, AlarmsState>((ref) {
  return AlarmsNotifier(ref.read(apiClientProvider));
});
