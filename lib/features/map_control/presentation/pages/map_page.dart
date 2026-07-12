import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/map_provider.dart';
import '../widgets/marker_info_window.dart';

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Interactive Map', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Text('Add google_maps_flutter to enable', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search controllers...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 16,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: state.filter == 'all',
                  onSelected: (_) => ref.read(mapProvider.notifier).setFilter('all'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Online'),
                  selected: state.filter == 'online',
                  onSelected: (_) => ref.read(mapProvider.notifier).setFilter('online'),
                  selectedColor: Colors.green.shade100,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Offline'),
                  selected: state.filter == 'offline',
                  onSelected: (_) => ref.read(mapProvider.notifier).setFilter('offline'),
                  selectedColor: Colors.red.shade100,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Nearby Controllers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: state.markers.length,
                      itemBuilder: (context, index) {
                        final marker = state.markers[index];
                        return MarkerInfoWindow(
                          marker: marker,
                          onTap: () => context.go('/controllers/${marker.controllerId}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
