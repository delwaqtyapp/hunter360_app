import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/l10n/app_localizations.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentPath = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    if (currentPath.startsWith('/map')) currentIndex = 1;
    else if (currentPath.startsWith('/controllers')) currentIndex = 2;
    else if (currentPath.startsWith('/alarms')) currentIndex = 3;
    else if (currentPath.startsWith('/settings')) currentIndex = 4;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context, l10n, currentPath),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/');
            case 1: context.go('/map');
            case 2: context.go('/controllers');
            case 3: context.go('/alarms');
            case 4: context.go('/settings');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: l10n.map,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.precision_manufacturing),
            label: l10n.controllers,
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.warning_amber),
            ),
            label: l10n.alarms,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations l10n, String currentPath) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1B5E20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 36, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text('Hunter 360', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Comprehensive Irrigation', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(context, Icons.dashboard, l10n.dashboard, '/', currentPath),
                  _drawerItem(context, Icons.map, l10n.map, '/map', currentPath),
                  _drawerItem(context, Icons.precision_manufacturing, l10n.controllers, '/controllers', currentPath),
                  _drawerItem(context, Icons.schedule, l10n.schedules, '/schedules', currentPath),
                  _drawerItem(context, Icons.water_drop, l10n.flowManagement, '/flow', currentPath),
                  _drawerItem(context, Icons.cloud, l10n.weather, '/weather', currentPath),
                  _drawerItem(context, Icons.warning_amber, l10n.alarms, '/alarms', currentPath),
                  _drawerItem(context, Icons.assessment, l10n.reports, '/reports', currentPath),
                  const Divider(),
                  _drawerItem(context, Icons.settings, l10n.settings, '/settings', currentPath),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
              onTap: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, String path, String currentPath) {
    final isSelected = currentPath == path;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF1B5E20) : null),
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedTileColor: const Color(0xFF1B5E20).withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        context.go(path);
      },
    );
  }
}
