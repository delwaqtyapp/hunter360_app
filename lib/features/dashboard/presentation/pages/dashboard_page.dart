import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(dashboardProvider.notifier).loadDashboard();
        ref.read(alarmsProvider.notifier).loadAlarms();
        ref.read(controllersProvider.notifier).loadControllers();
      },
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // --- Header ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0D3B4F), Color(0xFF156082)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Image.asset('assets/images/logo_hunter.png', height: 32, errorBuilder: (ctx, e, s) => const Icon(Icons.water_drop, color: Colors.white)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10n.appName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    Text(l10n.company, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ])),
                ]),
                const SizedBox(height: 8),
                Text(DateFormat('EEE, MMM dd, yyyy').format(DateTime.now()), style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // --- Stats Grid ---
          if (dashboardState.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: Color(0xFF156082))))
          else ...[
            Row(children: [
              Expanded(child: _statCard(Icons.settings_input_antenna, l10n.controllers, '${dashboardState.controllers.length}', l10n.online, const Color(0xFF4CAF50), () => context.go('/controllers'))),
              const SizedBox(width: 10),
              Expanded(child: _statCard(Icons.warning_amber, l10n.alarms, '${dashboardState.activeAlarms}', l10n.activeAlarms, dashboardState.activeAlarms > 0 ? const Color(0xFFF44336) : const Color(0xFF4CAF50), () => context.go('/alarms'))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _statCard(Icons.tag, l10n.totalTags, '${dashboardState.totalTags}', l10n.tagsCount, const Color(0xFF2196F3), () => context.go('/controllers'))),
              const SizedBox(width: 10),
              Expanded(child: _statCard(Icons.view_list, l10n.views, '3', l10n.operationStatus, const Color(0xFFFF9800), () => context.go('/diagnostics'))),
            ]),
          ],
          const SizedBox(height: 18),

          // --- Controllers ---
          if (controllersState.controllers.isNotEmpty) ...[
            _sectionHeader(l10n.projectControllers),
            const SizedBox(height: 8),
            ...controllersState.controllers.map((c) => Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: const Color(0xFF156082).withOpacity(0.1), child: const Icon(Icons.settings_input_antenna, color: Color(0xFF156082), size: 20)),
                title: Text(c.displayName.isNotEmpty && c.displayName != c.id ? '${c.id} - ${c.displayName}' : c.id, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('${c.tagCount} ${l10n.tagsCount}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(l10n.online, style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                ),
                onTap: () => context.go('/controllers'),
              ),
            )),
          ],
          const SizedBox(height: 14),

          // --- Quick Actions ---
          _sectionHeader(l10n.quickActions),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _quickAction(Icons.medical_information, l10n.diagnostics, () => context.go('/diagnostics'))),
            const SizedBox(width: 8),
            Expanded(child: _quickAction(Icons.play_circle, l10n.operationCommands, () => context.go('/operation-commands'))),
            const SizedBox(width: 8),
            Expanded(child: _quickAction(Icons.info, l10n.operationStatus, () => context.go('/operation-status'))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _quickAction(Icons.map, l10n.map, () => context.go('/map'))),
            const SizedBox(width: 8),
            Expanded(child: _quickAction(Icons.schedule, l10n.schedules, () => context.go('/schedules'))),
            const SizedBox(width: 8),
            Expanded(child: _quickAction(Icons.water, l10n.flowManagement, () => context.go('/flow'))),
          ]),
          const SizedBox(height: 18),

          // --- Recent Alarms ---
          if (alarmsState.alarms.isNotEmpty) ...[
            _sectionHeader('${l10n.recentAlarms} (${alarmsState.alarms.length})'),
            const SizedBox(height: 8),
            ...alarmsState.alarms.take(5).map((a) => Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                dense: true,
                leading: Icon(Icons.warning, color: a.priority >= 4 ? Colors.red : a.priority >= 2 ? Colors.orange : Colors.amber, size: 20),
                title: Text(a.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                subtitle: Text('${a.controllerName} - ${a.timestamp}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                trailing: Text('P${a.priority}', style: TextStyle(color: a.priority >= 4 ? Colors.red : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            )),
            if (alarmsState.alarms.length > 5)
              Center(child: TextButton(onPressed: () => context.go('/alarms'), child: Text(l10n.viewAll))),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF156082)));
  }

  Widget _statCard(IconData icon, String title, String value, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 2))],
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
            Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF156082).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF156082).withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: const Color(0xFF156082), size: 26),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
