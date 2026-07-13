import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/features/auth/presentation/providers/auth_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/controllers')) return 2;
    if (location.startsWith('/schedules')) return 3;
    if (location.startsWith('/alarms') || location.startsWith('/diagnostics') || location.startsWith('/operation')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _getCurrentIndex(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo_hunter.png', height: 28, errorBuilder: (ctx, e, s) => const Icon(Icons.water_drop, color: Colors.white)),
            const SizedBox(width: 8),
            Text(l10n.appName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        backgroundColor: const Color(0xFF156082),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push('/alarms')),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.push('/settings')),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF156082)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo_hunter.png', height: 48, errorBuilder: (ctx, e, s) => const Icon(Icons.water_drop, color: Colors.white, size: 48)),
                  const SizedBox(height: 8),
                  Text(l10n.appName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(l10n.company, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('v4.99.12', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            _drawerItem(context, Icons.dashboard, l10n.dashboard, '/'),
            const Divider(),
            _drawerItem(context, Icons.map, l10n.mapControl, '/map'),
            _drawerItem(context, Icons.settings_input_antenna, l10n.controllers, '/controllers'),
            _drawerItem(context, Icons.schedule, l10n.schedules, '/schedules'),
            _drawerItem(context, Icons.water, l10n.flowManagement, '/flow'),
            _drawerItem(context, Icons.wb_sunny, l10n.weather, '/weather'),
            const Divider(),
            _drawerItem(context, Icons.warning, l10n.alarms, '/alarms'),
            _drawerItem(context, Icons.medical_information, l10n.diagnostics, '/diagnostics'),
            _drawerItem(context, Icons.play_circle, l10n.operationCommands, '/operation-commands'),
            _drawerItem(context, Icons.info, l10n.operationStatus, '/operation-status'),
            const Divider(),
            _drawerItem(context, Icons.assessment, l10n.reports, '/reports'),
            _drawerItem(context, Icons.settings, l10n.settings, '/settings'),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/');
            case 1: context.go('/map');
            case 2: context.go('/controllers');
            case 3: context.go('/schedules');
            case 4: context.go('/alarms');
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF156082),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: l10n.dashboard),
          BottomNavigationBarItem(icon: const Icon(Icons.map), label: l10n.map),
          BottomNavigationBarItem(icon: const Icon(Icons.settings_input_antenna), label: l10n.controllers),
          BottomNavigationBarItem(icon: const Icon(Icons.schedule), label: l10n.schedules),
          BottomNavigationBarItem(icon: const Icon(Icons.warning), label: l10n.alarms),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF156082)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
