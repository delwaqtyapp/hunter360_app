import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';
import 'package:hunter360_app/core/utils/response_parser.dart';

class ScadaState {
  final String selectedController;
  final Map<String, String> tagValues;
  final List<Map<String, dynamic>> alarms;
  final List<double> currentDrawHistory;
  final bool isLoading;

  const ScadaState({
    this.selectedController = 'C001',
    this.tagValues = const {},
    this.alarms = const [],
    this.currentDrawHistory = const [],
    this.isLoading = false,
  });

  ScadaState copyWith({
    String? selectedController,
    Map<String, String>? tagValues,
    List<Map<String, dynamic>>? alarms,
    List<double>? currentDrawHistory,
    bool? isLoading,
  }) {
    return ScadaState(
      selectedController: selectedController ?? this.selectedController,
      tagValues: tagValues ?? this.tagValues,
      alarms: alarms ?? this.alarms,
      currentDrawHistory: currentDrawHistory ?? this.currentDrawHistory,
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

  static const _moduleNames = ['Module1', 'Module2', 'Module3'];
  static const _moduleTagParts = ['CurrentDraw', 'Overload', 'PathStatus', 'OutputMode'];

  static const _decoderTags = [
    'DecoderCommPercentage',
    'TotalDecoders',
    'ActiveDecoders',
    'DecoderWireTestStatus',
  ];

  static const _blockTagParts = ['CycleTime', 'SoakTime', 'HydraulicConnection', 'MasterValve', 'LinkFlowZone'];

  static const _controllerInfoTags = [
    'ControllerType',
    'FirmwareVersion',
    'StationSize',
    'IPAddress',
    'CommunicationProtocol',
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
    // Module tags
    for (final m in _moduleNames) {
      for (final p in _moduleTagParts) {
        tags.add('$c.$m.$p');
      }
    }
    // Decoder tags
    for (final t in _decoderTags) {
      tags.add('$c.$t');
    }
    // Block tags (up to 6 blocks)
    for (int i = 1; i <= 6; i++) {
      for (final p in _blockTagParts) {
        tags.add('$c.Block$i.$p');
      }
    }
    // Controller info tags
    for (final t in _controllerInfoTags) {
      tags.add('$c.$t');
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
      final alarms = ResponseParser.parseAlarmsList(response.data);
      final filtered = alarms.where((a) => a['TagGroup']?.toString() == state.selectedController).toList();
      state = state.copyWith(alarms: filtered);
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

  List<Map<String, String>> getModuleInfo(int moduleIndex) {
    final c = state.selectedController;
    final moduleName = _moduleNames[moduleIndex];
    return _moduleTagParts.map((p) {
      return {'label': p, 'value': _realtime.getValue('$c.$moduleName.$p')};
    }).toList();
  }

  Map<String, String> get decoderInfo {
    final c = state.selectedController;
    return {
      'commPercentage': _realtime.getValue('$c.DecoderCommPercentage'),
      'totalDecoders': _realtime.getValue('$c.TotalDecoders'),
      'activeDecoders': _realtime.getValue('$c.ActiveDecoders'),
      'wireTest': _realtime.getValue('$c.DecoderWireTestStatus'),
    };
  }

  List<Map<String, String>> getBlockInfo(int blockIndex) {
    final c = state.selectedController;
    final blockName = 'Block${blockIndex + 1}';
    return _blockTagParts.map((p) {
      return {'label': p, 'value': _realtime.getValue('$c.$blockName.$p')};
    }).toList();
  }

  Map<String, String> get controllerInfoData {
    final c = state.selectedController;
    final result = <String, String>{};
    for (final t in _controllerInfoTags) {
      result[t] = _realtime.getValue('$c.$t');
    }
    return result;
  }

  void recordCurrentDraw() {
    final c = state.selectedController;
    final value = double.tryParse(_realtime.getValue('$c.Module1.CurrentDraw')) ?? 0;
    final history = List<double>.from(state.currentDrawHistory);
    history.add(value);
    if (history.length > 30) history.removeAt(0);
    state = state.copyWith(currentDrawHistory: history);
  }

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
