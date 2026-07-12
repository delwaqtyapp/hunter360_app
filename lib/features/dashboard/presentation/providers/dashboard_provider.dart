import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/controller.dart';
import '../../domain/entities/weather_station.dart';

class DashboardState {
  final List<ControllerEntity> controllers;
  final List<WeatherStation> weatherStations;
  final double waterUsageToday;
  final double waterUsageMonth;
  final int activeAlarms;
  final int activeValves;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.controllers = const [],
    this.weatherStations = const [],
    this.waterUsageToday = 0,
    this.waterUsageMonth = 0,
    this.activeAlarms = 0,
    this.activeValves = 0,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    List<ControllerEntity>? controllers,
    List<WeatherStation>? weatherStations,
    double? waterUsageToday,
    double? waterUsageMonth,
    int? activeAlarms,
    int? activeValves,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      controllers: controllers ?? this.controllers,
      weatherStations: weatherStations ?? this.weatherStations,
      waterUsageToday: waterUsageToday ?? this.waterUsageToday,
      waterUsageMonth: waterUsageMonth ?? this.waterUsageMonth,
      activeAlarms: activeAlarms ?? this.activeAlarms,
      activeValves: activeValves ?? this.activeValves,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get onlineControllers => controllers.where((c) => c.isOnline).length;
  int get offlineControllers => controllers.where((c) => !c.isOnline).length;
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(
      isLoading: false,
      controllers: [
        ControllerEntity(id: '1', name: 'Controller ACC2-01', model: 'ACC2', status: 'online', ipAddress: '192.168.1.100', valveCount: 24, activeValves: 8, lastSeen: DateTime.now()),
        ControllerEntity(id: '2', name: 'Controller ICC2-02', model: 'ICC2', status: 'online', ipAddress: '192.168.1.101', valveCount: 12, activeValves: 4, lastSeen: DateTime.now()),
        ControllerEntity(id: '3', name: 'Controller ACC2-03', model: 'ACC2', status: 'offline', ipAddress: '192.168.1.102', valveCount: 36, activeValves: 0, lastSeen: DateTime.now().subtract(const Duration(hours: 2))),
        ControllerEntity(id: '4', name: 'Controller ICC2-04', model: 'ICC2', status: 'online', ipAddress: '192.168.1.103', valveCount: 18, activeValves: 6, lastSeen: DateTime.now()),
      ],
      weatherStations: [
        WeatherStation(id: 'ws1', name: 'Main Weather Station', type: 'WS-360-CELL', status: 'online', temperature: 32.5, humidity: 65, rainfall: 0, windSpeed: 12.3, soilMoisture: 45, lastReading: DateTime.now()),
      ],
      waterUsageToday: 12500,
      waterUsageMonth: 385000,
      activeAlarms: 3,
      activeValves: 18,
    );
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final notifier = DashboardNotifier();
  notifier.loadDashboard();
  return notifier;
});
