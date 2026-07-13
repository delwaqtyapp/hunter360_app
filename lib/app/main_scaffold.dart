import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo_hunter.png', height: 28, errorBuilder: (ctx, e, s) => const Icon(Icons.water_drop, color: Colors.white)),
            const SizedBox(width: 8),
            const Text('Abqarino SCADA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                  const Text('Abqarino SCADA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('v${const String.fromEnvironment("VERSION", defaultValue: "4.99.12")}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            _drawerItem(context, Icons.dashboard, 'Dashboard', '/'),
            const Divider(),
            _drawerItem(context, Icons.map, 'Map Control', '/map'),
            _drawerItem(context, Icons.settings_input_antenna, 'Controllers', '/controllers'),
            _drawerItem(context, Icons.schedule, 'Schedules', '/schedules'),
            _drawerItem(context, Icons.water, 'Flow Management', '/flow'),
            _drawerItem(context, Icons.wb_sunny, 'Weather', '/weather'),
            const Divider(),
            _drawerItem(context, Icons.warning, 'Alarms', '/alarms'),
            _drawerItem(context, Icons.medical_information, 'Diagnostics', '/diagnostics'),
            _drawerItem(context, Icons.play_circle, 'Operation Commands', '/operation-commands'),
            _drawerItem(context, Icons.info, 'Operation Status', '/operation-status'),
            const Divider(),
            _drawerItem(context, Icons.assessment, 'Reports', '/reports'),
            _drawerItem(context, Icons.settings, 'Settings', '/settings'),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_input_antenna), label: 'Controllers'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedules'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alarms'),
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
