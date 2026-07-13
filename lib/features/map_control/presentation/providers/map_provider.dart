import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import '../../domain/entities/map_marker.dart';

class MapState {
  final List<MapMarker> markers;
  final String typeFilter;
  final String statusFilter;
  final String searchQuery;
  final MapMarker? selectedMarker;
  final bool isLoading;
  final double zoomLevel;

  const MapState({
    this.markers = const [],
    this.typeFilter = 'all',
    this.statusFilter = 'all',
    this.searchQuery = '',
    this.selectedMarker,
    this.isLoading = false,
    this.zoomLevel = 1.0,
  });

  List<MapMarker> get filteredMarkers {
    var result = List<MapMarker>.from(markers);
    if (typeFilter != 'all') {
      final type = MarkerType.values.firstWhere(
        (t) => t.name == typeFilter,
        orElse: () => MarkerType.site,
      );
      result = result.where((m) => m.type == type).toList();
    }
    if (statusFilter != 'all') {
      result = result.where((m) => m.status == statusFilter).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where((m) =>
              m.name.toLowerCase().contains(q) ||
              m.id.toLowerCase().contains(q) ||
              m.description.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  MapState copyWith({
    List<MapMarker>? markers,
    String? typeFilter,
    String? statusFilter,
    String? searchQuery,
    MapMarker? selectedMarker,
    bool? isLoading,
    double? zoomLevel,
    bool clearSelected = false,
  }) {
    return MapState(
      markers: markers ?? this.markers,
      typeFilter: typeFilter ?? this.typeFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMarker: clearSelected ? null : (selectedMarker ?? this.selectedMarker),
      isLoading: isLoading ?? this.isLoading,
      zoomLevel: zoomLevel ?? this.zoomLevel,
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(const MapState()) {
    _loadMarkers();
  }

  void _loadMarkers() {
    state = state.copyWith(isLoading: true);

    final markers = <MapMarker>[
      const MapMarker(
        id: 'S001',
        controllerId: 'S001',
        name: 'LV (S001)',
        latitude: 30.04604251,
        longitude: 31.48238098,
        status: 'online',
        type: MarkerType.site,
        description: 'Lanoya Village - Active irrigation site',
        activeValves: 12,
      ),
      const MapMarker(
        id: 'S002',
        controllerId: 'S002',
        name: 'CBP (S002)',
        latitude: 30.0521432,
        longitude: 31.51349785,
        status: 'online',
        type: MarkerType.site,
        description: 'Cairo Business Park - Main site',
        activeValves: 30,
      ),
      const MapMarker(
        id: 'S003',
        controllerId: 'S003',
        name: 'KAI (S003)',
        latitude: 29.210836,
        longitude: 32.622661,
        status: 'online',
        type: MarkerType.site,
        description: 'KAI - Eastern irrigation site',
        activeValves: 8,
      ),
      const MapMarker(
        id: 'C002',
        controllerId: 'C002',
        name: 'CBP Controller (C002)',
        latitude: 30.1044560402046,
        longitude: 31.6309267461075,
        status: 'online',
        type: MarkerType.controller,
        description: 'Main CBP irrigation controller - ACC2',
        parentController: 'C002',
      ),

      // CBP Stations (STN1-STN30)
      const MapMarker(id: 'STN1', controllerId: 'C002', name: 'STN1', latitude: 30.05059153, longitude: 31.5129257, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN2', controllerId: 'C002', name: 'STN2', latitude: 30.05072097, longitude: 31.51260634, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN3', controllerId: 'C002', name: 'STN3', latitude: 30.05140766, longitude: 31.51233006, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN4', controllerId: 'C002', name: 'STN4', latitude: 30.05125409, longitude: 31.51227937, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN5', controllerId: 'C002', name: 'STN5', latitude: 30.05159415, longitude: 31.51242131, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN6', controllerId: 'C002', name: 'STN6', latitude: 30.05183548, longitude: 31.51271786, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN7', controllerId: 'C002', name: 'STN7', latitude: 30.05209874, longitude: 31.51289782, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN8', controllerId: 'C002', name: 'STN8', latitude: 30.052509, longitude: 31.51315128, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN9', controllerId: 'C002', name: 'STN9', latitude: 30.05262308, longitude: 31.51322986, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN10', controllerId: 'C002', name: 'STN10', latitude: 30.0528337, longitude: 31.51330589, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN11', controllerId: 'C002', name: 'STN11', latitude: 30.05317594, longitude: 31.51353654, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN12', controllerId: 'C002', name: 'STN12', latitude: 30.05317814, longitude: 31.51471768, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN13', controllerId: 'C002', name: 'STN13', latitude: 30.05308599, longitude: 31.51502184, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN14', controllerId: 'C002', name: 'STN14', latitude: 30.05272181, longitude: 31.51568084, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN15', controllerId: 'C002', name: 'STN15', latitude: 30.05260115, longitude: 31.5151511, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN16', controllerId: 'C002', name: 'STN16', latitude: 30.05244099, longitude: 31.51542991, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN17', controllerId: 'C002', name: 'STN17', latitude: 30.05190349, longitude: 31.51498635, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN18', controllerId: 'C002', name: 'STN18', latitude: 30.05223477, longitude: 31.51506746, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN19', controllerId: 'C002', name: 'STN19', latitude: 30.05228084, longitude: 31.51520179, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN20', controllerId: 'C002', name: 'STN20', latitude: 30.05221941, longitude: 31.5149458, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN21', controllerId: 'C002', name: 'STN21', latitude: 30.05207461, longitude: 31.51517645, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN22', controllerId: 'C002', name: 'STN22', latitude: 30.05085041, longitude: 31.51428933, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN23', controllerId: 'C002', name: 'STN23', latitude: 30.05138792, longitude: 31.51446929, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN24', controllerId: 'C002', name: 'STN24', latitude: 30.05122996, longitude: 31.51437804, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN25', controllerId: 'C002', name: 'STN25', latitude: 30.05055203, longitude: 31.51413979, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN26', controllerId: 'C002', name: 'STN26', latitude: 30.05054326, longitude: 31.51390407, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN27', controllerId: 'C002', name: 'STN27', latitude: 30.05097985, longitude: 31.51303722, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN28', controllerId: 'C002', name: 'STN28', latitude: 30.0511773, longitude: 31.51289782, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN29', controllerId: 'C002', name: 'STN29', latitude: 30.05154588, longitude: 31.51295612, status: 'online', type: MarkerType.station, parentController: 'C002'),
      const MapMarker(id: 'STN30', controllerId: 'C002', name: 'STN30', latitude: 30.0516479, longitude: 31.51300681, status: 'online', type: MarkerType.station, parentController: 'C002'),

      // CBP Flow Sensors
      const MapMarker(id: 'FSen1', controllerId: 'C002', name: 'Flow Sensor 1', latitude: 30.051763, longitude: 31.51354916, status: 'online', type: MarkerType.flowSensor, description: 'Main inlet flow sensor', parentController: 'C002'),
      const MapMarker(id: 'FSen2', controllerId: 'C002', name: 'Flow Sensor 2', latitude: 30.05149312, longitude: 31.513283, status: 'online', type: MarkerType.flowSensor, description: 'Zone B flow sensor', parentController: 'C002'),
      const MapMarker(id: 'FSen3', controllerId: 'C002', name: 'Flow Sensor 3', latitude: 30.0510499, longitude: 31.51439582, status: 'online', type: MarkerType.flowSensor, description: 'Zone C flow sensor', parentController: 'C002'),
      const MapMarker(id: 'FSen4', controllerId: 'C002', name: 'Flow Sensor 4', latitude: 30.05221061, longitude: 31.51431471, status: 'online', type: MarkerType.flowSensor, description: 'Zone D flow sensor', parentController: 'C002'),
      const MapMarker(id: 'FSen5', controllerId: 'C002', name: 'Flow Sensor 5', latitude: 30.05229399, longitude: 31.51478366, status: 'online', type: MarkerType.flowSensor, description: 'Zone E flow sensor', parentController: 'C002'),

      // CBP PMVs
      const MapMarker(id: 'Pmv1', controllerId: 'C002', name: 'PMV 1', latitude: 30.05179811, longitude: 31.51338186, status: 'online', type: MarkerType.pmv, description: 'Pressure relief valve zone A', parentController: 'C002'),
      const MapMarker(id: 'Pmv2', controllerId: 'C002', name: 'PMV 2', latitude: 30.05148215, longitude: 31.51315625, status: 'online', type: MarkerType.pmv, description: 'Pressure relief valve zone B', parentController: 'C002'),
      const MapMarker(id: 'Pmv3', controllerId: 'C002', name: 'PMV 3', latitude: 30.05105648, longitude: 31.51427922, status: 'online', type: MarkerType.pmv, description: 'Pressure relief valve zone C', parentController: 'C002'),
      const MapMarker(id: 'Pmv4', controllerId: 'C002', name: 'PMV 4', latitude: 30.05221719, longitude: 31.5141981, status: 'online', type: MarkerType.pmv, description: 'Pressure relief valve zone D', parentController: 'C002'),
      const MapMarker(id: 'Pmv5', controllerId: 'C002', name: 'PMV 5', latitude: 30.05230934, longitude: 31.51465945, status: 'online', type: MarkerType.pmv, description: 'Pressure relief valve zone E', parentController: 'C002'),
    ];

    state = state.copyWith(markers: markers, isLoading: false);
  }

  void setTypeFilter(String filter) {
    state = state.copyWith(typeFilter: filter);
  }

  void setStatusFilter(String filter) {
    state = state.copyWith(statusFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectMarker(MapMarker? marker) {
    state = state.copyWith(selectedMarker: marker, clearSelected: marker == null);
  }

  void setZoomLevel(double level) {
    state = state.copyWith(zoomLevel: level.clamp(0.5, 5.0));
  }

  void zoomIn() {
    state = state.copyWith(zoomLevel: (state.zoomLevel * 1.3).clamp(0.5, 5.0));
  }

  void zoomOut() {
    state = state.copyWith(zoomLevel: (state.zoomLevel / 1.3).clamp(0.5, 5.0));
  }

  List<MapMarker> getMarkersByType(MarkerType type) {
    return state.markers.where((m) => m.type == type).toList();
  }

  List<String> getControllerIds() {
    return AppConstants.controllers.map((c) => c['id']!).toList();
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
