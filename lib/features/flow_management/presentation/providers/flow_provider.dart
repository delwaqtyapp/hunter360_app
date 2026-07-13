import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/network/api_client.dart';

enum LearnFlowStatus { idle, learning, complete }

enum FlowZoneStatus { normal, high, low }

class FlowZone {
  final int index;
  final String name;
  final double flowTarget;
  final double maxFlowLimit;
  final double overFlowLimit;
  final double underFlowLimit;
  final double unscheduledFlowLimit;
  final double monthlyBudget;
  final double manualAllowance;
  final FlowZoneStatus status;
  final int priority;
  final double currentFlow;

  const FlowZone({
    required this.index,
    this.name = '',
    this.flowTarget = 0,
    this.maxFlowLimit = 0,
    this.overFlowLimit = 0,
    this.underFlowLimit = 0,
    this.unscheduledFlowLimit = 0,
    this.monthlyBudget = 0,
    this.manualAllowance = 0,
    this.status = FlowZoneStatus.normal,
    this.priority = 1,
    this.currentFlow = 0,
  });

  FlowZone copyWith({
    String? name,
    double? flowTarget,
    double? maxFlowLimit,
    double? overFlowLimit,
    double? underFlowLimit,
    double? unscheduledFlowLimit,
    double? monthlyBudget,
    double? manualAllowance,
    FlowZoneStatus? status,
    int? priority,
    double? currentFlow,
  }) {
    return FlowZone(
      index: index,
      name: name ?? this.name,
      flowTarget: flowTarget ?? this.flowTarget,
      maxFlowLimit: maxFlowLimit ?? this.maxFlowLimit,
      overFlowLimit: overFlowLimit ?? this.overFlowLimit,
      underFlowLimit: underFlowLimit ?? this.underFlowLimit,
      unscheduledFlowLimit: unscheduledFlowLimit ?? this.unscheduledFlowLimit,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      manualAllowance: manualAllowance ?? this.manualAllowance,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      currentFlow: currentFlow ?? this.currentFlow,
    );
  }
}

class HighFlowShutdownConfig {
  final bool enabled;
  final double threshold;
  final int autoResetMinutes;
  final bool isActive;

  const HighFlowShutdownConfig({
    this.enabled = false,
    this.threshold = 150.0,
    this.autoResetMinutes = 5,
    this.isActive = false,
  });

  HighFlowShutdownConfig copyWith({
    bool? enabled,
    double? threshold,
    int? autoResetMinutes,
    bool? isActive,
  }) {
    return HighFlowShutdownConfig(
      enabled: enabled ?? this.enabled,
      threshold: threshold ?? this.threshold,
      autoResetMinutes: autoResetMinutes ?? this.autoResetMinutes,
      isActive: isActive ?? this.isActive,
    );
  }
}

class CycleAndSoakConfig {
  final bool enabled;
  final int cycleTimeMinutes;
  final int soakTimeMinutes;

  const CycleAndSoakConfig({
    this.enabled = false,
    this.cycleTimeMinutes = 5,
    this.soakTimeMinutes = 30,
  });

  CycleAndSoakConfig copyWith({
    bool? enabled,
    int? cycleTimeMinutes,
    int? soakTimeMinutes,
  }) {
    return CycleAndSoakConfig(
      enabled: enabled ?? this.enabled,
      cycleTimeMinutes: cycleTimeMinutes ?? this.cycleTimeMinutes,
      soakTimeMinutes: soakTimeMinutes ?? this.soakTimeMinutes,
    );
  }
}

class FlowManagementState {
  final LearnFlowStatus learnFlowStatus;
  final double learnFlowProgress;
  final Map<String, String> learnFlowResults;
  final HighFlowShutdownConfig highFlowShutdown;
  final List<FlowZone> flowZones;
  final CycleAndSoakConfig cycleAndSoak;
  final double totalWaterSourceFlow;
  final bool isLoading;
  final String? error;

  const FlowManagementState({
    this.learnFlowStatus = LearnFlowStatus.idle,
    this.learnFlowProgress = 0.0,
    this.learnFlowResults = const {},
    this.highFlowShutdown = const HighFlowShutdownConfig(),
    this.flowZones = const [],
    this.cycleAndSoak = const CycleAndSoakConfig(),
    this.totalWaterSourceFlow = 0,
    this.isLoading = false,
    this.error,
  });

  FlowManagementState copyWith({
    LearnFlowStatus? learnFlowStatus,
    double? learnFlowProgress,
    Map<String, String>? learnFlowResults,
    HighFlowShutdownConfig? highFlowShutdown,
    List<FlowZone>? flowZones,
    CycleAndSoakConfig? cycleAndSoak,
    double? totalWaterSourceFlow,
    bool? isLoading,
    String? error,
  }) {
    return FlowManagementState(
      learnFlowStatus: learnFlowStatus ?? this.learnFlowStatus,
      learnFlowProgress: learnFlowProgress ?? this.learnFlowProgress,
      learnFlowResults: learnFlowResults ?? this.learnFlowResults,
      highFlowShutdown: highFlowShutdown ?? this.highFlowShutdown,
      flowZones: flowZones ?? this.flowZones,
      cycleAndSoak: cycleAndSoak ?? this.cycleAndSoak,
      totalWaterSourceFlow: totalWaterSourceFlow ?? this.totalWaterSourceFlow,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FlowManagementNotifier extends StateNotifier<FlowManagementState> {
  final ApiClient _apiClient;

  FlowManagementNotifier(this._apiClient) : super(const FlowManagementState()) {
    _init();
  }

  void _init() {
    state = state.copyWith(
      flowZones: List.generate(6, (i) {
        return FlowZone(
          index: i + 1,
          name: 'Zone ${i + 1}',
          flowTarget: 20.0 + (i * 2),
          maxFlowLimit: 30.0 + (i * 2),
          overFlowLimit: 35.0 + (i * 2),
          underFlowLimit: 10.0,
          unscheduledFlowLimit: 5.0,
          monthlyBudget: 50000,
          manualAllowance: 10,
          priority: i + 1,
          status: i < 4 ? FlowZoneStatus.normal : (i == 4 ? FlowZoneStatus.high : FlowZoneStatus.low),
          currentFlow: i < 5 ? 18.0 + (i * 1.5) : 0,
        );
      }),
      totalWaterSourceFlow: 120.0,
    );
  }

  void startLearnFlow() {
    state = state.copyWith(
      learnFlowStatus: LearnFlowStatus.learning,
      learnFlowProgress: 0.0,
    );

    Future.microtask(() async {
      for (int i = 0; i <= 100; i += 5) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        state = state.copyWith(learnFlowProgress: i.toDouble());
      }
      if (mounted) {
        state = state.copyWith(
          learnFlowStatus: LearnFlowStatus.complete,
          learnFlowProgress: 100.0,
          learnFlowResults: {
            'Zone 1': '22.3 GPM',
            'Zone 2': '19.8 GPM',
            'Zone 3': '25.1 GPM',
            'Zone 4': '18.5 GPM',
            'Zone 5': '21.0 GPM',
            'Zone 6': '0.0 GPM',
          },
        );
      }
    });
  }

  void resetLearnFlow() {
    state = state.copyWith(
      learnFlowStatus: LearnFlowStatus.idle,
      learnFlowProgress: 0.0,
      learnFlowResults: {},
    );
  }

  void toggleHighFlowShutdown() {
    state = state.copyWith(
      highFlowShutdown: state.highFlowShutdown.copyWith(
        enabled: !state.highFlowShutdown.enabled,
      ),
    );
  }

  void updateShutdownThreshold(double threshold) {
    state = state.copyWith(
      highFlowShutdown: state.highFlowShutdown.copyWith(threshold: threshold),
    );
  }

  void updateAutoResetTimer(int minutes) {
    state = state.copyWith(
      highFlowShutdown: state.highFlowShutdown.copyWith(autoResetMinutes: minutes),
    );
  }

  void updateFlowZone(int index, FlowZone Function(FlowZone) updater) {
    final zones = state.flowZones.map((z) {
      if (z.index == index) return updater(z);
      return z;
    }).toList();
    state = state.copyWith(flowZones: zones);
  }

  void toggleCycleAndSoak() {
    state = state.copyWith(
      cycleAndSoak: state.cycleAndSoak.copyWith(enabled: !state.cycleAndSoak.enabled),
    );
  }

  void updateCycleTime(int minutes) {
    state = state.copyWith(
      cycleAndSoak: state.cycleAndSoak.copyWith(cycleTimeMinutes: minutes),
    );
  }

  void updateSoakTime(int minutes) {
    state = state.copyWith(
      cycleAndSoak: state.cycleAndSoak.copyWith(soakTimeMinutes: minutes),
    );
  }

  void updateZonePriority(int zoneIndex, int priority) {
    updateFlowZone(zoneIndex, (z) => z.copyWith(priority: priority));
  }

  void updateTotalWaterSourceFlow(double flow) {
    state = state.copyWith(totalWaterSourceFlow: flow);
  }
}

final flowManagementProvider =
    StateNotifierProvider<FlowManagementNotifier, FlowManagementState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FlowManagementNotifier(apiClient);
});
