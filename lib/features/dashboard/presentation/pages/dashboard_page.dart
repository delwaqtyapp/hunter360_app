import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hunter360_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hunter360_app/features/alarms/presentation/providers/alarms_provider.dart';
import 'package:hunter360_app/features/controllers/presentation/providers/controllers_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(alarmsProvider.notifier).loadAlarms();
      ref.read(controllersProvider.notifier).loadControllers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final alarmsState = ref.watch(alarmsProvider);
    final controllersState = ref.watch(controllersProvider);
    final user = authState.user;

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(alarmsProvider.notifier).loadAlarms();
        ref.read(controllersProvider.notifier).loadControllers();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF388E3C)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text((user?.name ?? 'A')[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome, ${user?.name ?? 'Admin'}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(DateFormat('EEE, MMM dd, yyyy').format(DateTime.now()), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                    ],
                  ),
                ),
                Image.asset('assets/images/logo_hunter.png', height: 36, errorBuilder: (ctx, e, s) => const Icon(Icons.water_drop, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _statCard(Icons.settings_input_antenna, 'Controllers', '${controllersState.controllers.length}', 'Online', const Color(0xFF4CAF50), () => context.go('/controllers')),
              _statCard(Icons.warning_amber, 'Active Alarms', '${alarmsState.alarms.length}', 'Current', alarmsState.alarms.isNotEmpty ? const Color(0xFFF44336) : const Color(0xFF4CAF50), () => context.go('/alarms')),
              _statCard(Icons.water_drop, 'Flow Rate', '0.0', 'm3/h', const Color(0xFF2196F3), () => context.go('/flow')),
              _statCard(Icons.wb_sunny, 'Weather', '--', 'C', const Color(0xFFFF9800), () => context.go('/weather')),
            ],
          ),
          const SizedBox(height: 20),
          _sectionHeader('Quick Actions'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _quickAction(Icons.map, 'Map View', () => context.go('/map')),
              _quickAction(Icons.schedule, 'Schedules', () => context.go('/schedules')),
              _quickAction(Icons.assessment, 'Reports', () => context.go('/reports')),
              _quickAction(Icons.water, 'Flow Mgmt', () => context.go('/flow')),
              _quickAction(Icons.devices, 'Devices', () => context.go('/controllers')),
              _quickAction(Icons.settings, 'Settings', () => context.go('/settings')),
            ],
          ),
          const SizedBox(height: 20),
          if (alarmsState.alarms.isNotEmpty) ...[
            _sectionHeader('Recent Alarms'),
            const SizedBox(height: 8),
            ...alarmsState.alarms.take(5).map((a) => Card(
              child: ListTile(
                leading: Icon(Icons.warning, color: a.priority >= 4 ? Colors.red : Colors.orange),
                title: Text(a.message),
                subtitle: Text(a.timestamp),
                trailing: Text('P${a.priority}', style: TextStyle(color: a.priority >= 4 ? Colors.red : Colors.orange, fontWeight: FontWeight.bold)),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)));
  }

  Widget _statCard(IconData icon, String title, String value, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))],
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text('$title - $subtitle', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1B5E20).withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1B5E20), size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
