import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/app_scaffold.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/map_control/presentation/pages/map_page.dart';
import '../features/controllers/presentation/pages/controllers_list_page.dart';
import '../features/controllers/presentation/pages/controller_detail_page.dart';
import '../features/schedules/presentation/pages/schedules_page.dart';
import '../features/flow_management/presentation/pages/flow_page.dart';
import '../features/weather/presentation/pages/weather_page.dart';
import '../features/alarms/presentation/pages/alarms_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/map',
            name: 'map',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MapPage(),
            ),
          ),
          GoRoute(
            path: '/controllers',
            name: 'controllers',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ControllersListPage(),
            ),
          ),
          GoRoute(
            path: '/controllers/:id',
            name: 'controller-detail',
            builder: (context, state) => ControllerDetailPage(
              controllerId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/schedules',
            name: 'schedules',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SchedulesPage(),
            ),
          ),
          GoRoute(
            path: '/flow',
            name: 'flow',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FlowPage(),
            ),
          ),
          GoRoute(
            path: '/weather',
            name: 'weather',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WeatherPage(),
            ),
          ),
          GoRoute(
            path: '/alarms',
            name: 'alarms',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AlarmsPage(),
            ),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsPage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
    ],
  );
});
