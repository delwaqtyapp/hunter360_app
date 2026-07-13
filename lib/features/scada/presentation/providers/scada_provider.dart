import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';

class ScadaState {
  final String selectedController;
  final Map<String, String> tagValues;
  final List<Map<String, dynamic>> alarms;
  final bool isLoading;

  const ScadaState({
    this.selectedController = 'C001',
    this.tagValues = const {},
    this.alarms = const [],
    this.isLoading = false,
  });

  ScadaState copyWith({String? selectedController, Map<String, String>? tagValues, List<Map<String, dynamic>>? alarms, bool? isLoading}) {
    return ScadaState(
      selectedController: selectedController ?? this.selectedController,
      tagValues: tagValues ?? this.tagValues,
      alarms: alarms ?? this.alarms,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ScadaNotifier extends StateNotifier<ScadaState> {
  final ApiClient _apiClient;
  final RealtimeService _realtime;

  static const _diagnosticTags = [
    'Station Size is Zero',
    'Power Outage Detected',
    'Max. Transformer Current',
    'Decoder Module is Overloaded',
    'Low Voltage Fault Detected',
    'Station Fault Detected',
    'P/MV Fault Detected',
    'Sensor Decoder Fault Detected',
    'Station Flow Alarm Detected',
    'MainSafe/Flow Zone Alarm Detected',
    'Clik Sensor Alarm Detected',
    'Weather Sensor Com. Fault',
    'RTC Fault Detected',
    'CAN Bus Fault Detected',
    'Weather Sensor Alarm Detected',
    'Clik Sensor Rain Delay Alarm',
    'NWW Violation Detected',
    'Weather Sensor Rain Delay Alarm',
  ];

  static const _infoTags = [
    'Controller is Irrigating',
    'Shutdown is Active',
    'Days off Active',
    'Controller Suspend is Active',
    'Controller Pause is Active',
    'Clik Sensor is Active',
    'Station Size Changed',
    'Controller Inventory Changed',
    'Data was Reset',
    'Configuration was Updated',
    'Mute is Active',
    'Time/Date was Updated',
    'Active Event List Full',
    'A Program was Stopped',
    'A Block was Stopped',
    'A Station or PMV was Stopped',
    'All Irrigation was Stopped',
    'Condition Response Statement Started',
    'Weather Sensor is Active',
    'Decoder Wire Test Mode Active',
    'Controller flow Diagnostic is Active',
  ];

  ScadaNotifier(this._apiClient, this._realtime) : super(const ScadaState());

  void setController(String controllerId) {
    state = state.copyWith(selectedController: controllerId);
    _subscribeTags();
    _loadAlarms();
  }

  void _subscribeTags() {
    final c = state.selectedController;
    final tags = <String>[];
    for (final t in _diagnosticTags) {
      tags.add('$c.ReportAlarmsInformation_${t.replaceAll(' ', '').replaceAll('.', '')}_Status');
    }
    for (final t in _infoTags) {
      tags.add('$c.ReportAlarmsInformation_${t.replaceAll(' ', '').replaceAll('.', '')}_Status');
    }
    _realtime.subscribe(tags);
  }

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    _subscribeTags();
    _realtime.start();
    await _loadAlarms();
    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadAlarms() async {
    try {
      final response = await _apiClient.get(ApiConstants.alarmsCurrent);
      final data = response.data;
      final List alarmsList = (data is Map) ? (data['Alarms'] ?? data['Data'] ?? []) : [];
      final filtered = alarmsList.where((a) => a['TagGroup']?.toString() == state.selectedController).toList();
      state = state.copyWith(alarms: List<Map<String, dynamic>>.from(filtered));
    } catch (_) {}
  }

  List<Map<String, String>> get diagnosticItems {
    return _diagnosticTags.map((t) {
      final tagName = '${state.selectedController}.ReportAlarmsInformation_${t.replaceAll(' ', '').replaceAll('.', '')}_Status';
      return {'label': t, 'tagName': tagName};
    }).toList();
  }

  List<Map<String, String>> get infoItems {
    return _infoTags.map((t) {
      final tagName = '${state.selectedController}.ReportAlarmsInformation_${t.replaceAll(' ', '').replaceAll('.', '')}_Status';
      return {'label': t, 'tagName': tagName};
    }).toList();
  }

  String getTagValue(String tagName) => _realtime.getValue(tagName);
  String getTagStatus(String tagName) => _realtime.getStatus(tagName);

  Future<void> sendCommand(String tagName, String value) async {
    try {
      await _apiClient.post(ApiConstants.tagsWrite, data: [
        {'TagName': tagName, 'RawValue': value},
      ], contentType: 'application/json');
    } catch (_) {}
  }
}

final scadaProvider = StateNotifierProvider<ScadaNotifier, ScadaState>((ref) {
  final api = ref.read(apiClientProvider);
  final realtime = ref.read(realtimeServiceProvider);
  return ScadaNotifier(api, realtime);
});
