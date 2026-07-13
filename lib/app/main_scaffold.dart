import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/theme/app_theme.dart';
import 'package:hunter360_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hunter360_app/core/network/api_client.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/controllers') || location.startsWith('/sites')) return 2;
    if (location.startsWith('/schedules')) return 3;
    if (location.startsWith('/alarms') ||
        location.startsWith('/diagnostics') ||
        location.startsWith('/operation')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _getCurrentIndex(context);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final serverUrl = ref.watch(serverUrlProvider);

    return Scaffold(
      appBar: _SCADAAppBar(l10n: l10n, isDark: isDark, serverUrl: serverUrl),
      drawer: _SCADADrawer(l10n: l10n, ref: ref, isDark: isDark, serverUrl: serverUrl),
      body: child,
      bottomNavigationBar: _SCADABottomNav(
        currentIndex: currentIndex,
        l10n: l10n,
        isDark: isDark,
        context: context,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  APP BAR
// ═══════════════════════════════════════════════════════════════════
class _SCADAAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final String serverUrl;

  const _SCADAAppBar({
    required this.l10n,
    required this.isDark,
    required this.serverUrl,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [AppTheme.darkSurface, AppTheme.darkSurface],
              )
            : AppTheme.darkAppBarGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            // Logo with glow
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryLight.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo_hunter.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: Icon(Icons.water_drop, color: Colors.white, size: 20),
                    ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // App name + connection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: serverUrl.isNotEmpty ? AppTheme.successColor : AppTheme.errorColor,
                        boxShadow: [
                          BoxShadow(
                            color: (serverUrl.isNotEmpty
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor)
                                .withOpacity(0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      serverUrl.isNotEmpty
                          ? l10n.connectedToServerStatus
                          : l10n.notConnectedToServerStatus,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Notification bell with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                onPressed: () => context.push('/alarms'),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.errorColor.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          // Settings gear
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DRAWER
// ═══════════════════════════════════════════════════════════════════
class _SCADADrawer extends StatelessWidget {
  final AppLocalizations l10n;
  final WidgetRef ref;
  final bool isDark;
  final String serverUrl;

  const _SCADADrawer({
    required this.l10n,
    required this.ref,
    required this.isDark,
    required this.serverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();

    return Drawer(
      child: Column(
        children: [
          // ── Gradient Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
            decoration: const BoxDecoration(
              gradient: AppTheme.drawerHeaderGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with ring
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo_hunter.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white24,
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 36),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.company,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                // Server URL pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dns, size: 12, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          serverUrl.isEmpty ? l10n.tapToConfigure : serverUrl,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Navigation Items ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                _sectionLabel(l10n.mainSection),
                _drawerItem(
                  context, Icons.dashboard_rounded, l10n.dashboard, '/',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.map_rounded, l10n.mapControl, '/map',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.location_city_rounded, l10n.sitesTitle, '/sites',
                  currentLocation, isDark,
                ),

                const SizedBox(height: 4),
                _sectionLabel(l10n.irrigationSection),
                _drawerItem(
                  context, Icons.settings_input_antenna_rounded, l10n.controllers, '/controllers',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.schedule_rounded, l10n.schedules, '/schedules',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.edit_calendar_rounded, l10n.scheduleEditorTitle, '/schedules/editor',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.water_drop_rounded, l10n.flowManagement, '/flow',
                  currentLocation, isDark,
                ),

                const SizedBox(height: 4),
                _sectionLabel(l10n.monitoringSection),
                _drawerItem(
                  context, Icons.wb_sunny_rounded, l10n.weather, '/weather',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.sync_rounded, l10n.solarSyncTitle, '/weather/solar-sync',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.grass_rounded, l10n.etCalculationTitle, '/weather/et',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.warning_amber_rounded, l10n.alarms, '/alarms',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.history_rounded, l10n.alarmHistoryTitle, '/alarms/history',
                  currentLocation, isDark,
                ),

                const SizedBox(height: 4),
                _sectionLabel(l10n.systemSection),
                _drawerItem(
                  context, Icons.medical_information_rounded, l10n.diagnostics, '/diagnostics',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.play_circle_outline_rounded, l10n.operationCommands, '/operation-commands',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.info_outline_rounded, l10n.operationStatus, '/operation-status',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.trending_up_rounded, l10n.trendTitle, '/trends',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.assessment_rounded, l10n.reports, '/reports',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.security_rounded, l10n.securityTitle, '/security',
                  currentLocation, isDark,
                ),
                _drawerItem(
                  context, Icons.settings_rounded, l10n.settings, '/settings',
                  currentLocation, isDark,
                ),
              ],
            ),
          ),

          // ── Logout Button ──
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                color: AppTheme.errorColor.withOpacity(0.06),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded, color: AppTheme.errorColor, size: 20),
                ),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppTheme.lightTextSecondary.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
    String currentLocation,
    bool isDark,
  ) {
    final isActive = currentLocation == route || currentLocation.startsWith('$route/');
    final color = isActive ? AppTheme.primaryColor : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(context);
            context.go(route);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isActive
                  ? AppTheme.primaryColor.withOpacity(isDark ? 0.15 : 0.08)
                  : Colors.transparent,
              border: isActive
                  ? const Border(
                      left: BorderSide(
                        color: AppTheme.primaryColor,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryColor.withOpacity(isDark ? 0.2 : 0.12)
                        : (isDark ? Colors.white60 : AppTheme.lightDivider).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isActive ? AppTheme.primaryColor : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: color,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BOTTOM NAVIGATION
// ═══════════════════════════════════════════════════════════════════
class _SCADABottomNav extends StatelessWidget {
  final int currentIndex;
  final AppLocalizations l10n;
  final bool isDark;
  final BuildContext context;

  const _SCADABottomNav({
    required this.currentIndex,
    required this.l10n,
    required this.isDark,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkSurface.withOpacity(0.92)
                : Colors.white.withOpacity(0.88),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppTheme.darkDivider.withOpacity(0.5)
                    : AppTheme.lightDivider,
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(0, Icons.dashboard_rounded, l10n.dashboard),
                  _navItem(1, Icons.map_rounded, l10n.map),
                  _navItem(2, Icons.settings_input_antenna_rounded, l10n.controllers),
                  _navItem(3, Icons.schedule_rounded, l10n.schedules),
                  _navItem(4, Icons.warning_amber_rounded, l10n.alarms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = currentIndex == index;
    final color = isActive ? AppTheme.primaryColor : AppTheme.lightTextSecondary;

    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0: context.go('/');
          case 1: context.go('/map');
          case 2: context.go('/controllers');
          case 3: context.go('/schedules');
          case 4: context.go('/alarms');
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive
              ? AppTheme.primaryColor.withOpacity(isDark ? 0.15 : 0.08)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 16 : 0,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
