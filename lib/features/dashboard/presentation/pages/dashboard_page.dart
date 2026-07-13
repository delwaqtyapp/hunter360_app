import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hunter360_app/features/alarms/presentation/providers/alarms_provider.dart';
import 'package:hunter360_app/features/controllers/presentation/providers/controllers_provider.dart';
import 'package:hunter360_app/features/dashboard/presentation/providers/dashboard_provider.dart';

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
      ref.read(dashboardProvider.notifier).loadDashboard();
      ref.read(alarmsProvider.notifier).loadAlarms();
      ref.read(controllersProvider.notifier).loadControllers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final alarmsState = ref.watch(alarmsProvider);
    final controllersState = ref.watch(controllersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(dashboardProvider.notifier).loadDashboard();
        ref.read(alarmsProvider.notifier).loadAlarms();
        ref.read(controllersProvider.notifier).loadControllers();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0D3B4F), Color(0xFF156082)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Text('A', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Abqarino SCADA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(DateFormat('EEE, MMM dd, yyyy').format(DateTime.now()), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                    ],
                  ),
                ),
                Image.asset('assets/images/logo_hunter.png', height: 36, errorBuilder: (ctx, e, s) => const Icon(Icons.water_drop, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (dashboardState.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF156082))))
          else ...[
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _statCard(Icons.settings_input_antenna, 'Controllers', '${dashboardState.controllers.length}', 'Active', const Color(0xFF4CAF50), () => context.go('/controllers')),
                _statCard(Icons.warning_amber, 'Alarms', '${dashboardState.activeAlarms}', 'Current', dashboardState.activeAlarms > 0 ? const Color(0xFFF44336) : const Color(0xFF4CAF50), () => context.go('/alarms')),
                _statCard(Icons.tag, 'Tags', '${dashboardState.totalTags}', 'Registered', const Color(0xFF2196F3), () => context.go('/controllers')),
                _statCard(Icons.view_list, 'Views', '3', 'Available', const Color(0xFFFF9800), () => context.go('/reports')),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _sectionHeader('Quick Actions'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _quickAction(Icons.medical_information, 'Diagnostics', () => context.go('/diagnostics')),
              _quickAction(Icons.play_circle, 'Commands', () => context.go('/operation-commands')),
              _quickAction(Icons.info, 'Status', () => context.go('/operation-status')),
              _quickAction(Icons.map, 'Map', () => context.go('/map')),
              _quickAction(Icons.schedule, 'Schedules', () => context.go('/schedules')),
              _quickAction(Icons.water, 'Flow', () => context.go('/flow')),
            ],
          ),
          const SizedBox(height: 20),
          if (controllersState.controllers.isNotEmpty) ...[
            _sectionHeader('Controllers'),
            const SizedBox(height: 8),
            ...controllersState.controllers.map((c) => Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: const Color(0xFF156082).withOpacity(0.1), child: const Icon(Icons.settings_input_antenna, color: Color(0xFF156082))),
                title: Text('${c.name} (${c.displayName})'),
                subtitle: Text('${c.tagCount} tags'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/controllers'),
              ),
            )),
          ],
          const SizedBox(height: 20),
          if (alarmsState.alarms.isNotEmpty) ...[
            _sectionHeader('Recent Alarms (${alarmsState.alarms.length})'),
            const SizedBox(height: 8),
            ...alarmsState.alarms.take(5).map((a) => Card(
              child: ListTile(
                leading: Icon(Icons.warning, color: a.priority >= 4 ? Colors.red : a.priority >= 2 ? Colors.orange : Colors.amber),
                title: Text(a.message, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${a.controllerName} - ${a.timestamp}'),
                trailing: Text('P${a.priority}', style: TextStyle(color: a.priority >= 4 ? Colors.red : Colors.orange, fontWeight: FontWeight.bold)),
              ),
            )),
            if (alarmsState.alarms.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(child: TextButton(onPressed: () => context.go('/alarms'), child: const Text('View All Alarms'))),
              ),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF156082)));
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
          color: const Color(0xFF156082).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF156082).withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: const Color(0xFF156082), size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
