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
import '../features/alarms/presentation/pages/alarms_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import 'main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapPage(),
          ),
          GoRoute(
            path: '/controllers',
            builder: (context, state) => const ControllersListPage(),
          ),
          GoRoute(
            path: '/controllers/:id',
            builder: (context, state) => ControllerDetailPage(
              controllerId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/schedules',
            builder: (context, state) => const SchedulesPage(),
          ),
          GoRoute(
            path: '/schedules/editor',
            builder: (context, state) => const ScheduleEditorPage(),
          ),
          GoRoute(
            path: '/flow',
            builder: (context, state) => const FlowPage(),
          ),
          GoRoute(
            path: '/weather',
            builder: (context, state) => const WeatherPage(),
          ),
          GoRoute(
            path: '/alarms',
            builder: (context, state) => const AlarmsPage(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});
