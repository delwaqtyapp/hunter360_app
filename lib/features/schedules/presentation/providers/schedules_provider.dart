import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/schedule.dart';

class SchedulesState {
  final List<Schedule> schedules;
  final bool isLoading;

  const SchedulesState({this.schedules = const [], this.isLoading = false});
}

class SchedulesNotifier extends StateNotifier<SchedulesState> {
  SchedulesNotifier() : super(const SchedulesState()) {
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    state = SchedulesState(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = SchedulesState(schedules: [
      Schedule(id: '1', controllerId: '1', name: 'Main Schedule', enabled: true, seasonalAdjustment: 100,
        programs: [
          Program(id: 'p1', name: 'Morning Watering', startTimeMinutes: 360, runTimes: [10, 15, 20, 8, 12]),
          Program(id: 'p2', name: 'Evening Watering', startTimeMinutes: 1080, runTimes: [8, 12, 15, 5, 10]),
        ]),
      Schedule(id: '2', controllerId: '2', name: 'Green Area', enabled: true, seasonalAdjustment: 80,
        programs: [
          Program(id: 'p3', name: 'Day Schedule', startTimeMinutes: 480, runTimes: [15, 20, 10]),
        ]),
      Schedule(id: '3', controllerId: '3', name: 'Backup Schedule', enabled: false, seasonalAdjustment: 60),
    ]);
  }

  Future<void> toggleSchedule(String id) async {
    state = SchedulesState(
      schedules: state.schedules.map((s) => s.id == id ? Schedule(id: s.id, controllerId: s.controllerId, name: s.name, enabled: !s.enabled, programs: s.programs, seasonalAdjustment: s.seasonalAdjustment) : s).toList(),
      isLoading: false,
    );
  }

  void updateSeasonalAdjustment(String id, int value) {
    state = SchedulesState(
      schedules: state.schedules.map((s) => s.id == id ? Schedule(id: s.id, controllerId: s.controllerId, name: s.name, enabled: s.enabled, programs: s.programs, seasonalAdjustment: value) : s).toList(),
      isLoading: false,
    );
  }
}

final schedulesProvider = StateNotifierProvider<SchedulesNotifier, SchedulesState>((ref) {
  return SchedulesNotifier();
});
