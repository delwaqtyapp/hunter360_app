import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';

class SiteInfo {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String controllerId;
  final int totalStations;
  final int flowSensors;
  final int pmvs;
  final bool isOnline;

  const SiteInfo({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.controllerId,
    required this.totalStations,
    required this.flowSensors,
    required this.pmvs,
    this.isOnline = false,
  });

  SiteInfo copyWith({bool? isOnline}) {
    return SiteInfo(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      controllerId: controllerId,
      totalStations: totalStations,
      flowSensors: flowSensors,
      pmvs: pmvs,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  static const List<SiteInfo> defaultSites = [
    SiteInfo(
      id: 'S001',
      name: 'Lanova (LV)',
      latitude: 30.04604251,
      longitude: 31.48238098,
      controllerId: 'C001',
      totalStations: 165,
      flowSensors: 3,
      pmvs: 3,
    ),
    SiteInfo(
      id: 'S002',
      name: 'CBP',
      latitude: 30.0521432,
      longitude: 31.51349785,
      controllerId: 'C002',
      totalStations: 47,
      flowSensors: 5,
      pmvs: 5,
    ),
    SiteInfo(
      id: 'S003',
      name: 'KAI',
      latitude: 29.210836,
      longitude: 32.622661,
      controllerId: 'C003',
      totalStations: 40,
      flowSensors: 1,
      pmvs: 1,
    ),
  ];
}

class SitesState {
  final List<SiteInfo> sites;
  final bool isLoading;
  final String? error;

  const SitesState({
    this.sites = SiteInfo.defaultSites,
    this.isLoading = false,
    this.error,
  });

  SitesState copyWith({
    List<SiteInfo>? sites,
    bool? isLoading,
    String? error,
  }) {
    return SitesState(
      sites: sites ?? this.sites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SitesNotifier extends StateNotifier<SitesState> {
  final RealtimeService _realtimeService;

  SitesNotifier(this._realtimeService) : super(const SitesState()) {
    _checkControllerStatus();
  }

  void _checkControllerStatus() {
    final controllerTags = [
      'C001.Status',
      'C002.Status',
      'C003.Status',
    ];
    _realtimeService.subscribe(controllerTags);

    _realtimeService.tagValuesStream.listen((values) {
      final updatedSites = state.sites.map((site) {
        final tag = '${site.controllerId}.Status';
        final value = values[tag]?.scaledValue ?? '';
        final isOnline = value.isNotEmpty && value != '0' && value.toLowerCase() != 'offline';
        return site.copyWith(isOnline: isOnline);
      }).toList();
      state = state.copyWith(sites: updatedSites);
    });
  }

  Future<void> refreshStatus() async {
    _realtimeService.fetchOnce(['C001.Status', 'C002.Status', 'C003.Status']);
  }
}

final sitesProvider = StateNotifierProvider<SitesNotifier, SitesState>((ref) {
  final realtimeService = ref.read(realtimeServiceProvider);
  return SitesNotifier(realtimeService);
});
