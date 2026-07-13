import 'package:flutter/material.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import '../../domain/entities/map_marker.dart';

Color getMarkerColor(MarkerType type) {
  switch (type) {
    case MarkerType.site:
      return Colors.blue;
    case MarkerType.controller:
      return Colors.green;
    case MarkerType.station:
      return Colors.orange;
    case MarkerType.flowSensor:
      return Colors.cyan;
    case MarkerType.pmv:
      return Colors.red;
  }
}

String getMarkerTypeName(MarkerType type, AppLocalizations l10n) {
  switch (type) {
    case MarkerType.site:
      return l10n.site;
    case MarkerType.controller:
      return l10n.controller;
    case MarkerType.station:
      return l10n.station;
    case MarkerType.flowSensor:
      return l10n.flowSensor;
    case MarkerType.pmv:
      return l10n.pmv;
  }
}

IconData getMarkerIcon(MarkerType type) {
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

class MarkerInfoWindow extends StatelessWidget {
  final MapMarker marker;
  final VoidCallback? onTap;
  final bool compact;

  const MarkerInfoWindow({
    super.key,
    required this.marker,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = getMarkerColor(marker.type);
    final l10n = AppLocalizations.of(context);

    if (compact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(getMarkerIcon(marker.type), size: 14, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      marker.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                getMarkerTypeName(marker.type, l10n),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: marker.isOnline ? Colors.green : Colors.red,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(getMarkerIcon(marker.type), size: 14, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    marker.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              getMarkerTypeName(marker.type, l10n),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            if (marker.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                marker.description,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: marker.isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  marker.isOnline ? l10n.online : l10n.offline,
                  style: TextStyle(
                    fontSize: 11,
                    color: marker.isOnline ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MarkerDetailSheet extends StatelessWidget {
  final MapMarker marker;
  final VoidCallback? onNavigate;

  const MarkerDetailSheet({
    super.key,
    required this.marker,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final color = getMarkerColor(marker.type);
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(getMarkerIcon(marker.type), color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marker.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        getMarkerTypeName(marker.type, l10n),
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: marker.isOnline
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: marker.isOnline
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Text(
                    marker.isOnline ? l10n.online : l10n.offline,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: marker.isOnline
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildDetailRow(l10n.controllerId, marker.controllerId, Icons.tag),
                  if (marker.parentController.isNotEmpty)
                    _buildDetailRow(l10n.parentController, marker.parentController, Icons.account_tree),
                  _buildDetailRow(
                    l10n.latitudeLabel,
                    marker.latitude.toStringAsFixed(8),
                    Icons.my_location,
                  ),
                  _buildDetailRow(
                    l10n.longitudeLabel,
                    marker.longitude.toStringAsFixed(8),
                    Icons.explore,
                  ),
                  if (marker.activeValves > 0)
                    _buildDetailRow(
                      l10n.activeValves,
                      '${marker.activeValves}',
                      Icons.water_drop,
                    ),
                ],
              ),
            ),
          ),
          if (marker.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                marker.description,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onNavigate,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(l10n.viewDetails),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
