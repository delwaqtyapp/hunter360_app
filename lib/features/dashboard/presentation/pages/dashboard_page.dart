import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/weather_widget.dart';
import '../widgets/quick_actions.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WeatherWidget(),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  title: 'Active Controllers',
                  value: '${state.onlineControllers}',
                  subtitle: '${state.offlineControllers} offline',
                  icon: Icons.precision_manufacturing,
                  color: Colors.green,
                  onTap: () => context.go('/controllers'),
                ),
                StatCard(
                  title: 'Active Valves',
                  value: '${state.activeValves}',
                  subtitle: 'Running now',
                  icon: Icons.water_drop,
                  color: Colors.blue,
                ),
                StatCard(
                  title: 'Water Today',
                  value: '${(state.waterUsageToday / 1000).toStringAsFixed(1)}K',
                  subtitle: 'Liters',
                  icon: Icons.opacity,
                  color: Colors.cyan,
                ),
                StatCard(
                  title: 'Alarms',
                  value: '${state.activeAlarms}',
                  subtitle: 'Active alerts',
                  icon: Icons.warning_amber,
                  color: state.activeAlarms > 0 ? Colors.red : Colors.green,
                  onTap: () => context.go('/alarms'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const QuickActions(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Controllers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.go('/controllers'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...state.controllers.take(3).map((c) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: c.isOnline ? Colors.green.shade100 : Colors.red.shade100,
                  child: Icon(
                    Icons.precision_manufacturing,
                    color: c.isOnline ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(c.name),
                subtitle: Text('${c.model} - ${c.activeValves}/${c.valveCount} valves active'),
                trailing: Icon(
                  Icons.circle,
                  size: 12,
                  color: c.isOnline ? Colors.green : Colors.red,
                ),
                onTap: () => context.go('/controllers/${c.id}'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
