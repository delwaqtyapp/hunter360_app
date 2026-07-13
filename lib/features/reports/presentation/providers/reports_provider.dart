import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';

enum ReportPeriod { daily, weekly, monthly, yearly }

class ZoneFlowData {
  final String zoneName;
  final double value;
  final int zoneIndex;

  const ZoneFlowData({
    required this.zoneName,
    required this.value,
    required this.zoneIndex,
  });
}

class FlowReading {
  final String label;
  final double value;
  final DateTime timestamp;

  const FlowReading({
    required this.label,
    required this.value,
    required this.timestamp,
  });
}

class ReportsState {
  final String selectedController;
  final ReportPeriod selectedPeriod;
  final List<ZoneFlowData> zoneFlowData;
  final List<FlowReading> trendData;
  final bool isLoading;
  final String? error;
  final double totalFlow;
  final DateTime fromDate;
  final DateTime toDate;

  const ReportsState({
    this.selectedController = 'C001',
    this.selectedPeriod = ReportPeriod.daily,
    this.zoneFlowData = const [],
    this.trendData = const [],
    this.isLoading = false,
    this.error,
    this.totalFlow = 0,
    required this.fromDate,
    required this.toDate,
  });

  ReportsState copyWith({
    String? selectedController,
    ReportPeriod? selectedPeriod,
    List<ZoneFlowData>? zoneFlowData,
    List<FlowReading>? trendData,
    bool? isLoading,
    String? error,
    double? totalFlow,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return ReportsState(
      selectedController: selectedController ?? this.selectedController,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      zoneFlowData: zoneFlowData ?? this.zoneFlowData,
      trendData: trendData ?? this.trendData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalFlow: totalFlow ?? this.totalFlow,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  final ApiClient _apiClient;

  ReportsNotifier(this._apiClient)
      : super(ReportsState(
          fromDate: DateTime.now().subtract(const Duration(days: 7)),
          toDate: DateTime.now(),
        )) {
    loadFlowData();
  }

  static const _zoneColors = [
    '0xFF2196F3', // Blue Zone 1
    '0xFF4CAF50', // Green Zone 2
    '0xFFFF9800', // Orange Zone 3
    '0xFFF44336', // Red Zone 4
    '0xFF9C27B0', // Purple Zone 5
    '0xFF795548', // Brown Zone 6
  ];

  String _getFlowTag(int zoneIndex) {
    final controller = state.selectedController;
    final zoneNum = zoneIndex + 1;
    return '$controller.FlowSensor$zoneNum.TotalFlow';
  }

  Future<void> loadFlowData() async {
    state = state.copyWith(isLoading: true);
    try {
      final tagNames = List.generate(6, (i) => _getFlowTag(i));
      final query = tagNames.map((t) => 'TagName=$t').join('&');
      final url = '${ApiConstants.tagsValuesList}?$query';

      final response = await _apiClient.get(url);
      final data = response.data;

      final Map<String, dynamic> tagsMap = Map<String, dynamic>.from(
        data is Map ? data : {},
      );
      final List tags = (tagsMap['Tags'] ?? tagsMap['Data'] ?? []) as List;

      double total = 0;
      final zoneData = <ZoneFlowData>[];

      for (int i = 0; i < 6; i++) {
        double value = 0;
        for (final tag in tags) {
          final tagMap = Map<String, dynamic>.from(tag is Map ? tag : {});
          final name = tagMap['Name']?.toString() ?? tagMap['TagName']?.toString() ?? '';
          if (name.contains('FlowSensor${i + 1}')) {
            value = (tagMap['Value'] ?? tagMap['RawValue'] ?? 0).toDouble();
            break;
          }
        }
        total += value;
        zoneData.add(ZoneFlowData(
          zoneName: 'Zone ${i + 1}',
          value: value,
          zoneIndex: i,
        ));
      }

      final trendData = _generateTrendData(zoneData);

      state = state.copyWith(
        zoneFlowData: zoneData,
        trendData: trendData,
        totalFlow: total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        zoneFlowData: _getMockZoneData(),
        trendData: _getMockTrendData(),
        totalFlow: _getMockZoneData().fold<double>(0.0, (sum, z) => sum + z.value),
      );
    }
  }

  void setController(String controllerId) {
    state = state.copyWith(selectedController: controllerId);
    loadFlowData();
  }

  void setPeriod(ReportPeriod period) {
    state = state.copyWith(selectedPeriod: period);
    loadFlowData();
  }

  void setDateRange(DateTime from, DateTime to) {
    state = state.copyWith(fromDate: from, toDate: to);
    loadFlowData();
  }

  List<FlowReading> _generateTrendData(List<ZoneFlowData> zoneData) {
    final now = DateTime.now();
    final readings = <FlowReading>[];

    int points;
    switch (state.selectedPeriod) {
      case ReportPeriod.daily:
        points = 24;
        break;
      case ReportPeriod.weekly:
        points = 7;
        break;
      case ReportPeriod.monthly:
        points = 30;
        break;
      case ReportPeriod.yearly:
        points = 12;
        break;
    }

    for (int i = 0; i < points; i++) {
      final total = zoneData.fold(0.0, (sum, z) => sum + z.value);
      final variance = (i % 3 == 0 ? 0.85 : i % 3 == 1 ? 1.1 : 0.95);
      readings.add(FlowReading(
        label: _getTrendLabel(i),
        value: (total * variance / points * 3).clamp(0, double.infinity),
        timestamp: now.subtract(Duration(hours: points - i)),
      ));
    }
    return readings;
  }

  String _getTrendLabel(int index) {
    switch (state.selectedPeriod) {
      case ReportPeriod.daily:
        return '${index}h';
      case ReportPeriod.weekly:
        final days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
        return days[index % 7];
      case ReportPeriod.monthly:
        return '${index + 1}';
      case ReportPeriod.yearly:
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return months[index % 12];
    }
  }

  List<ZoneFlowData> _getMockZoneData() {
    return [
      const ZoneFlowData(zoneName: 'Zone 1', value: 125.5, zoneIndex: 0),
      const ZoneFlowData(zoneName: 'Zone 2', value: 98.3, zoneIndex: 1),
      const ZoneFlowData(zoneName: 'Zone 3', value: 145.8, zoneIndex: 2),
      const ZoneFlowData(zoneName: 'Zone 4', value: 87.2, zoneIndex: 3),
      const ZoneFlowData(zoneName: 'Zone 5', value: 110.6, zoneIndex: 4),
      const ZoneFlowData(zoneName: 'Zone 6', value: 76.9, zoneIndex: 5),
    ];
  }

  List<FlowReading> _getMockTrendData() {
    return List.generate(
      7,
      (i) => FlowReading(
        label: ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'][i],
        value: 100 + (i * 15.5) - (i % 2 == 0 ? 20 : 0),
        timestamp: DateTime.now().subtract(Duration(days: 6 - i)),
      ),
    );
  }
}

final reportsProvider = StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier(ref.read(apiClientProvider));
});
