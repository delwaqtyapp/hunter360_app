import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/alarm.dart';

class AlarmsState {
  final List<Alarm> alarms;
  final String filter;
  final bool isLoading;

  const AlarmsState({this.alarms = const [], this.filter = 'all', this.isLoading = false});

  List<Alarm> get filteredAlarms {
    if (filter == 'all') return alarms;
    if (filter == 'active') return alarms.where((a) => !a.acknowledged).toList();
    return alarms.where((a) => a.severity.toLowerCase() == filter).toList();
  }

  int get activeCount => alarms.where((a) => !a.acknowledged).length;
}

class AlarmsNotifier extends StateNotifier<AlarmsState> {
  AlarmsNotifier() : super(const AlarmsState()) {
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    state = AlarmsState(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = AlarmsState(alarms: [
      Alarm(id: '1', controllerId: '1', controllerName: 'ACC2-01', type: 'flow', severity: 'warning', message: 'Flow rate below threshold on Zone 3', timestamp: DateTime.now().subtract(const Duration(minutes: 15)), acknowledged: false),
      Alarm(id: '2', controllerId: '2', controllerName: 'ICC2-02', type: 'communication', severity: 'critical', message: 'Communication lost with controller', timestamp: DateTime.now().subtract(const Duration(hours: 1)), acknowledged: false),
      Alarm(id: '3', controllerId: '1', controllerName: 'ACC2-01', type: 'weather', severity: 'info', message: 'Weather station updated', timestamp: DateTime.now().subtract(const Duration(hours: 2)), acknowledged: true),
      Alarm(id: '4', controllerId: '3', controllerName: 'ACC2-03', type: 'system', severity: 'error', message: 'Controller offline since 2 hours', timestamp: DateTime.now().subtract(const Duration(hours: 2)), acknowledged: false),
      Alarm(id: '5', controllerId: '4', controllerName: 'ICC2-04', type: 'flow', severity: 'warning', message: 'High flow rate detected on Zone 7', timestamp: DateTime.now().subtract(const Duration(minutes: 45)), acknowledged: true),
    ]);
  }

  void setFilter(String filter) {
    state = AlarmsState(alarms: state.alarms, filter: filter, isLoading: false);
  }

  void acknowledgeAlarm(String id) {
    state = AlarmsState(
      alarms: state.alarms.map((a) => a.id == id ? Alarm(id: a.id, controllerId: a.controllerId, controllerName: a.controllerName, type: a.type, severity: a.severity, message: a.message, timestamp: a.timestamp, acknowledged: true) : a).toList(),
      filter: state.filter,
    );
  }
}

final alarmsProvider = StateNotifierProvider<AlarmsNotifier, AlarmsState>((ref) {
  return AlarmsNotifier();
});
