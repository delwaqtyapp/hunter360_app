import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_localizations.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentRoute = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    if (currentRoute.startsWith('/map')) currentIndex = 1;
    else if (currentRoute.startsWith('/controllers')) currentIndex = 2;
    else if (currentRoute.startsWith('/alarms')) currentIndex = 3;
    else if (currentRoute == '/settings' ||
        currentRoute.startsWith('/schedules') ||
        currentRoute.startsWith('/flow') ||
        currentRoute.startsWith('/weather') ||
        currentRoute.startsWith('/reports')) currentIndex = 4;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HUNTER',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '360',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 20,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      drawer: _buildDrawer(context, l10n, currentRoute),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/map');
              break;
            case 2:
              context.go('/controllers');
              break;
            case 3:
              context.go('/alarms');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: l10n.map,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_input_component_outlined),
            activeIcon: const Icon(Icons.settings_input_component),
            label: l10n.controllers,
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: const Text('3', style: TextStyle(fontSize: 10)),
              child: const Icon(Icons.warning_outlined),
            ),
            activeIcon: const Badge(
              label: Text('3', style: TextStyle(fontSize: 10)),
              child: Icon(Icons.warning),
            ),
            label: l10n.alarms,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz_outlined),
            activeIcon: const Icon(Icons.more_horiz),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations l10n, String currentRoute) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Admin User',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'admin@hunter360.com',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(context, Icons.dashboard, l10n.dashboard, '/', currentRoute),
                  _buildDrawerItem(context, Icons.map, l10n.map, '/map', currentRoute),
                  _buildDrawerItem(context, Icons.settings_input_component, l10n.controllers, '/controllers', currentRoute),
                  _buildDrawerItem(context, Icons.schedule, l10n.schedules, '/schedules', currentRoute),
                  _buildDrawerItem(context, Icons.water, l10n.flowManagement, '/flow', currentRoute),
                  _buildDrawerItem(context, Icons.cloud, l10n.weather, '/weather', currentRoute),
                  _buildDrawerItem(context, Icons.warning, l10n.alarms, '/alarms', currentRoute),
                  _buildDrawerItem(context, Icons.assessment, l10n.reports, '/reports', currentRoute),
                  const Divider(),
                  _buildDrawerItem(context, Icons.settings, l10n.settings, '/settings', currentRoute),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'v1.0.0',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route, String currentRoute) {
    final isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF1B5E20) : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF1B5E20) : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
