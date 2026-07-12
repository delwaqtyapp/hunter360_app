import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/controllers')) return 2;
    if (location.startsWith('/schedules')) return 3;
    if (location.startsWith('/alarms')) return 4;
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
            const Text('Hunter 360', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF1B5E20),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/alarms'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1B5E20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo_hunter.png', height: 48, errorBuilder: (ctx, e, s) => const Icon(Icons.water_drop, color: Colors.white, size: 48)),
                  const SizedBox(height: 8),
                  const Text('Hunter 360', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('SCADA Mobile', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            _drawerItem(context, Icons.dashboard, 'Dashboard', '/'),
            _drawerItem(context, Icons.map, 'Map Control', '/map'),
            _drawerItem(context, Icons.settings_input_antenna, 'Controllers', '/controllers'),
            _drawerItem(context, Icons.schedule, 'Schedules', '/schedules'),
            _drawerItem(context, Icons.water, 'Flow Management', '/flow'),
            _drawerItem(context, Icons.wb_sunny, 'Weather', '/weather'),
            _drawerItem(context, Icons.warning, 'Alarms', '/alarms'),
            _drawerItem(context, Icons.assessment, 'Reports', '/reports'),
            const Divider(),
            _drawerItem(context, Icons.dashboard_customize, 'Dashboards', '/settings'),
            _drawerItem(context, Icons.person, 'User Management', '/settings'),
            _drawerItem(context, Icons.devices, 'Device Management', '/settings'),
            const Divider(),
            _drawerItem(context, Icons.settings, 'Settings', '/settings'),
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
        selectedItemColor: const Color(0xFF1B5E20),
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
      leading: Icon(icon, color: const Color(0xFF1B5E20)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
