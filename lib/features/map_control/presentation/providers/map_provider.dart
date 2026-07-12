import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/map_marker.dart';

class MapState {
  final List<MapMarker> markers;
  final String filter;
  final bool isLoading;

  const MapState({
    this.markers = const [],
    this.filter = 'all',
    this.isLoading = false,
  });

  List<MapMarker> get filteredMarkers {
    if (filter == 'all') return markers;
    return markers.where((m) => m.status == filter).toList();
  }
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(const MapState()) {
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isLoading: false,
      markers: const [
        MapMarker(id: '1', controllerId: '1', name: 'ACC2-01', latitude: 30.0444, longitude: 31.2357, status: 'online', activeValves: 8),
        MapMarker(id: '2', controllerId: '2', name: 'ICC2-02', latitude: 30.0454, longitude: 31.2367, status: 'online', activeValves: 4),
        MapMarker(id: '3', controllerId: '3', name: 'ACC2-03', latitude: 30.0434, longitude: 31.2347, status: 'offline', activeValves: 0),
        MapMarker(id: '4', controllerId: '4', name: 'ICC2-04', latitude: 30.0464, longitude: 31.2377, status: 'online', activeValves: 6),
      ],
    );
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
