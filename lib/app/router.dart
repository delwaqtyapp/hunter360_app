import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/map_control/presentation/pages/map_page.dart';
import '../features/controllers/presentation/pages/controllers_list_page.dart';
import '../features/controllers/presentation/pages/controller_detail_page.dart';
import '../features/schedules/presentation/pages/schedules_page.dart';
import '../features/schedules/presentation/pages/schedule_editor_page.dart';
import '../features/flow_management/presentation/pages/flow_page.dart';
import '../features/weather/presentation/pages/weather_page.dart';
import '../features/weather/presentation/pages/solar_sync_page.dart';
import '../features/weather/presentation/pages/et_calculation_page.dart';
import '../features/alarms/presentation/pages/alarms_page.dart';
import '../features/alarms/presentation/pages/alarm_history_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/scada/presentation/pages/diagnostics_page.dart';
import '../features/scada/presentation/pages/operation_commands_page.dart';
import '../features/scada/presentation/pages/operation_status_page.dart';
import '../features/trends/presentation/pages/trends_page.dart';
import '../features/security/presentation/pages/security_page.dart';
import '../features/sites/presentation/pages/sites_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoginRoute = state.uri.toString() == '/login';
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
          GoRoute(path: '/map', builder: (context, state) => const MapPage()),
          GoRoute(path: '/sites', builder: (context, state) => const SitesPage()),
          GoRoute(path: '/controllers', builder: (context, state) => const ControllersListPage()),
          GoRoute(path: '/controllers/:id', builder: (context, state) => ControllerDetailPage(controllerId: state.pathParameters['id']!)),
          GoRoute(path: '/schedules', builder: (context, state) => const SchedulesPage()),
          GoRoute(path: '/schedules/editor', builder: (context, state) => const ScheduleEditorPage()),
          GoRoute(path: '/flow', builder: (context, state) => const FlowPage()),
          GoRoute(path: '/weather', builder: (context, state) => const WeatherPage()),
          GoRoute(path: '/weather/solar-sync', builder: (context, state) => const SolarSyncPage()),
          GoRoute(path: '/weather/et', builder: (context, state) => const ETCalculationPage()),
          GoRoute(path: '/alarms', builder: (context, state) => const AlarmsPage()),
          GoRoute(path: '/alarms/history', builder: (context, state) => const AlarmHistoryPage()),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsPage()),
          GoRoute(path: '/trends', builder: (context, state) => const TrendsPage()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
          GoRoute(path: '/security', builder: (context, state) => const SecurityPage()),
          GoRoute(path: '/diagnostics', builder: (context, state) => const DiagnosticsPage()),
          GoRoute(path: '/operation-commands', builder: (context, state) => const OperationCommandsPage()),
          GoRoute(path: '/operation-status', builder: (context, state) => const OperationStatusPage()),
        ],
      ),
    ],
  );
});
