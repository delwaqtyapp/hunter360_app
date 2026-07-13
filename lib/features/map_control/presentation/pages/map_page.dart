import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';
import '../providers/map_provider.dart';
import '../widgets/marker_info_window.dart';
import '../../domain/entities/map_marker.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  MapMarker? _bottomSheetMarker;
  bool _mapReady = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  LatLngBounds _calculateBounds(List<MapMarker> markers) {
    if (markers.isEmpty) {
      return LatLngBounds(
        const LatLng(30.04, 31.48),
        const LatLng(30.06, 31.52),
      );
    }
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final m in markers) {
      if (m.latitude < minLat) minLat = m.latitude;
      if (m.latitude > maxLat) maxLat = m.latitude;
      if (m.longitude < minLng) minLng = m.longitude;
      if (m.longitude > maxLng) maxLng = m.longitude;
    }
    final padding = 0.005;
    return LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final filteredMarkers = state.filteredMarkers;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Stack(
        children: [
          // Real map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(30.052, 31.513),
              initialZoom: 13,
              minZoom: 3,
              maxZoom: 18,
              onMapReady: () => setState(() => _mapReady = true),
              onTap: (_, __) {
                setState(() => _bottomSheetMarker = null);
                ref.read(mapProvider.notifier).selectMarker(null);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.abqarino.scada',
                maxZoom: 18,
              ),
              // Draw lines between stations of same controller
              if (filteredMarkers.length > 2)
                PolylineLayer(
                  polylines: _buildControllerPolylines(filteredMarkers),
                ),
              // Markers
              MarkerLayer(
                markers: filteredMarkers.map((marker) => _buildMarker(marker)).toList(),
              ),
              // Attribution
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),

          // Search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _buildSearchBar(l10n, colorScheme),
          ),

          // Filter chips
          Positioned(
            top: MediaQuery.of(context).padding.top + 68,
            left: 0,
            right: 0,
            child: _buildFilterChips(state, l10n, colorScheme),
          ),

          // Site quick-select buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 112,
            left: 16,
            child: _buildSiteButtons(state, l10n, colorScheme),
          ),

          // Marker count badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 112,
            right: 16,
            child: _buildMarkerCount(state, l10n, colorScheme),
          ),

          // Legend
          Positioned(
            left: 16,
            bottom: _bottomSheetMarker != null ? 280 : 20,
            child: _buildLegend(l10n, colorScheme),
          ),

          // Bottom sheet
          if (_bottomSheetMarker != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MarkerDetailSheet(
                marker: _bottomSheetMarker!,
                onNavigate: () => _navigateToMarker(_bottomSheetMarker!),
              ),
            ),
        ],
      ),
    );
  }

  List<Polyline> _buildControllerPolylines(List<MapMarker> markers) {
    final controllerGroups = <String, List<MapMarker>>{};
    for (final m in markers) {
      if (m.type == MarkerType.station) {
        controllerGroups.putIfAbsent(m.parentController, () => []).add(m);
      }
    }

    final polylines = <Polyline>[];
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
    int i = 0;
    for (final entry in controllerGroups.entries) {
      if (entry.value.length > 1) {
        final points = entry.value
            .map((m) => LatLng(m.latitude, m.longitude))
            .toList();
        polylines.add(Polyline(
          points: points,
          color: colors[i % colors.length].withOpacity(0.4),
          strokeWidth: 2,
        ));
      }
      i++;
    }
    return polylines;
  }

  Marker _buildMarker(MapMarker marker) {
    final color = getMarkerColor(marker.type);
    final size = _getMarkerSize(marker.type);
    final icon = _getMarkerIcon(marker.type);

    return Marker(
      point: LatLng(marker.latitude, marker.longitude),
      width: size,
      height: size + (marker.type == MarkerType.site ? 14 : 0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(mapProvider.notifier).selectMarker(marker);
          setState(() => _bottomSheetMarker = marker);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: size * 0.5),
            ),
            if (marker.type == MarkerType.site)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 3),
                  ],
                ),
                child: Text(
                  marker.name.split('(').first.trim(),
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: color),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getMarkerSize(MarkerType type) {
    switch (type) {
      case MarkerType.site:
        return 38;
      case MarkerType.controller:
        return 32;
      case MarkerType.station:
        return 20;
      case MarkerType.flowSensor:
        return 22;
      case MarkerType.pmv:
        return 22;
    }
  }

  IconData _getMarkerIcon(MarkerType type) {
    switch (type) {
      case MarkerType.site:
        return Icons.location_on;
      case MarkerType.controller:
        return Icons.settings_input_antenna;
      case MarkerType.station:
        return Icons.water_drop;
      case MarkerType.flowSensor:
        return Icons.speed;
      case MarkerType.pmv:
        return Icons.power;
    }
  }

  Widget _buildSearchBar(AppLocalizations l10n, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => ref.read(mapProvider.notifier).setSearchQuery(val),
        decoration: InputDecoration(
          hintText: l10n.searchMap,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(mapProvider.notifier).setSearchQuery('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips(MapState state, AppLocalizations l10n, ColorScheme colorScheme) {
    final chips = <Map<String, dynamic>>[
      {'label': l10n.allTypes, 'value': 'all', 'color': colorScheme.primary},
      {'label': l10n.sitesLabel, 'value': 'site', 'color': Colors.blue},
      {'label': l10n.controller, 'value': 'controller', 'color': Colors.green},
      {'label': l10n.stationsLabel, 'value': 'station', 'color': Colors.orange},
      {'label': l10n.flowSensorsLabel, 'value': 'flowSensor', 'color': Colors.cyan},
      {'label': l10n.pmvsLabel, 'value': 'pmv', 'color': Colors.red},
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final isSelected = state.typeFilter == chip['value'];
          final chipColor = chip['color'] as Color;

          return FilterChip(
            label: Text(
              chip['label'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : chipColor,
              ),
            ),
            selected: isSelected,
            onSelected: (_) {
              HapticFeedback.selectionClick();
              ref.read(mapProvider.notifier).setTypeFilter(chip['value'] as String);
            },
            selectedColor: chipColor,
            backgroundColor: colorScheme.surface,
            side: BorderSide(
              color: isSelected ? chipColor : chipColor.withOpacity(0.3),
              width: isSelected ? 0 : 1,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  Widget _buildSiteButtons(MapState state, AppLocalizations l10n, ColorScheme colorScheme) {
    final sites = [
      {'name': 'LV', 'lat': 30.04604251, 'lng': 31.48238098, 'zoom': 15.0},
      {'name': 'CBP', 'lat': 30.0521432, 'lng': 31.51349785, 'zoom': 16.0},
      {'name': 'KAI', 'lat': 29.210836, 'lng': 32.622661, 'zoom': 15.0},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: sites.map((site) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                _mapController.move(
                  LatLng(site['lat'] as double, site['lng'] as double),
                  site['zoom'] as double,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  site['name'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMarkerCount(MapState state, AppLocalizations l10n, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4),
        ],
      ),
      child: Text(
        '${state.filteredMarkers.length} ${l10n.markersFound}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildLegend(AppLocalizations l10n, ColorScheme colorScheme) {
    final items = [
      {'label': l10n.site, 'color': Colors.blue, 'icon': Icons.location_on},
      {'label': l10n.controller, 'color': Colors.green, 'icon': Icons.settings_input_antenna},
      {'label': l10n.station, 'color': Colors.orange, 'icon': Icons.water_drop},
      {'label': l10n.flowSensor, 'color': Colors.cyan, 'icon': Icons.speed},
      {'label': l10n.pmv, 'color': Colors.red, 'icon': Icons.power},
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: item['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'] as IconData, color: Colors.white, size: 8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item['label'] as String,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _navigateToMarker(MapMarker marker) {
    setState(() => _bottomSheetMarker = null);
    ref.read(mapProvider.notifier).selectMarker(null);

    switch (marker.type) {
      case MarkerType.controller:
      case MarkerType.site:
        final id = marker.id.startsWith('S') ? 'C002' : marker.id;
        context.go('/controllers/$id');
        break;
      case MarkerType.station:
      case MarkerType.flowSensor:
      case MarkerType.pmv:
        context.go('/controllers/${marker.parentController}');
        break;
    }
  }
}
