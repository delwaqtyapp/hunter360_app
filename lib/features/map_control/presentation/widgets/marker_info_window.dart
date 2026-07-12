import 'package:flutter/material.dart';
import '../../domain/entities/map_marker.dart';

class MarkerInfoWindow extends StatelessWidget {
  final MapMarker marker;
  final VoidCallback? onTap;

  const MarkerInfoWindow({super.key, required this.marker, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: marker.isOnline ? Colors.green : Colors.red,
            width: 2,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: marker.isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    marker.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.water_drop, size: 14, color: Colors.blue.shade600),
                const SizedBox(width: 4),
                Text(
                  '${marker.activeValves} valves',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              marker.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 11,
                color: marker.isOnline ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
