import 'package:equatable/equatable.dart';

class Schedule extends Equatable {
  final String id;
  final String controllerId;
  final String name;
  final bool enabled;
  final List<Program> programs;
  final int seasonalAdjustment;

  const Schedule({
    required this.id,
    required this.controllerId,
    required this.name,
    this.enabled = true,
    this.programs = const [],
    this.seasonalAdjustment = 100,
  });

  @override
  List<Object?> get props => [id, name, enabled, programs, seasonalAdjustment];
}

class Program extends Equatable {
  final String id;
  final String name;
  final int startTimeMinutes;
  final List<int> runTimes;
  final List<int> days; // 0-6 (Sun-Sat)
  final bool oddEvenDays;

  const Program({
    required this.id,
    required this.name,
    this.startTimeMinutes = 360, // 6:00 AM
    this.runTimes = const [],
    this.days = const [0, 1, 2, 3, 4, 5, 6],
    this.oddEvenDays = false,
  });

  @override
  List<Object?> get props => [id, name, startTimeMinutes, runTimes, days];
}
