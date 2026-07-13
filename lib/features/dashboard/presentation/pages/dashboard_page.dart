import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/theme/app_theme.dart';
import 'package:hunter360_app/core/widgets/gauge_widget.dart';
import 'package:hunter360_app/core/widgets/led_indicator.dart';
import 'package:hunter360_app/core/widgets/flow_meter_widget.dart';
import 'package:hunter360_app/features/alarms/presentation/providers/alarms_provider.dart';
import 'package:hunter360_app/features/controllers/presentation/providers/controllers_provider.dart';
import 'package:hunter360_app/features/dashboard/presentation/providers/dashboard_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> with TickerProviderStateMixin {
  Timer? _clockTimer;
  String _timeStr = '';
  String _dateEn = '';
  String _dateAr = '';
  late AnimationController _headerGlowController;

  @override
  void initState() {
    super.initState();
    _headerGlowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
    Future.microtask(() {
      ref.read(dashboardProvider.notifier).loadDashboard();
      ref.read(alarmsProvider.notifier).loadAlarms();
      ref.read(controllersProvider.notifier).loadControllers();
    });
  }

  void _updateClock() {
    final now = DateTime.now();
    setState(() {
      _timeStr = DateFormat('HH:mm:ss').format(now);
      _dateEn = DateFormat('EEE, dd MMM yyyy').format(now);
      _dateAr = DateFormat('EEEE, dd MMMM yyyy', 'ar').format(now);
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _headerGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardProvider);
    final alarmsState = ref.watch(alarmsProvider);
    final controllersState = ref.watch(controllersProvider);
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(dashboardProvider.notifier).loadDashboard();
        await ref.read(alarmsProvider.notifier).loadAlarms();
        await ref.read(controllersProvider.notifier).loadControllers();
      },
      color: AppTheme.primaryColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: CustomScrollView(
        slivers: [
          if (dashState.error != null && !dashState.isConnected)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppTheme.errorColor.withOpacity(0.15),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: AppTheme.errorColor, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        dashState.error!.contains('Exception')
                            ? l10n.serverUnavailable
                            : dashState.error!,
                        style: const TextStyle(color: AppTheme.errorColor, fontSize: 11, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(dashboardProvider.notifier).loadDashboard(),
                      child: Text(l10n.retry, style: const TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(child: _buildHeader(l10n, isArabic, dashState)),
          SliverToBoxAdapter(child: _buildSystemStatusRow(l10n, dashState)),
          SliverToBoxAdapter(child: _buildControllerCards(l10n, controllersState, dashState)),
          SliverToBoxAdapter(child: _buildFlowMetersSection(l10n, dashState)),
          SliverToBoxAdapter(child: _buildQuickActions(l10n)),
          SliverToBoxAdapter(child: _buildRecentAlarms(l10n, alarmsState)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, bool isArabic, DashboardState dashState) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2E44), Color(0xFF0D3B4F), Color(0xFF156082)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo_hunter.png',
                    height: 36,
                    errorBuilder: (_, __, ___) => Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.water_drop, color: Color(0xFF00E676), size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.appName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(l10n.company, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_timeStr, style: const TextStyle(color: Color(0xFF00E676), fontSize: 16, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.tabularFigures()])),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _headerGlowController,
                            builder: (_, __) => Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dashState.isConnected ? const Color(0xFF00E676) : Colors.red,
                                boxShadow: [
                                  BoxShadow(
                                    color: (dashState.isConnected ? const Color(0xFF00E676) : Colors.red).withOpacity(0.4 + _headerGlowController.value * 0.4),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dashState.isConnected ? l10n.connected : l10n.disconnected,
                            style: TextStyle(color: dashState.isConnected ? const Color(0xFF00E676) : Colors.red, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(_dateEn, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
              if (isArabic) Text(_dateAr, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatusRow(AppLocalizations l10n, DashboardState dashState) {
    return Container(
      color: const Color(0xFF0A1929),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildMetricChip(
              l10n.runningStations,
              '${dashState.runningStations}',
              LedColor.green,
              dashState.runningStations > 0,
              const Color(0xFF4CAF50),
            ),
            const SizedBox(width: 8),
            _buildMetricChip(
              l10n.activeAlarms,
              '${dashState.activeAlarms}',
              LedColor.red,
              dashState.activeAlarms > 0,
              const Color(0xFFF44336),
              pulse: dashState.activeAlarms > 0,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: GaugeWidget(
                value: dashState.totalFlowRate,
                minValue: 0,
                maxValue: 500,
                unit: 'L/min',
                size: GaugeSize.small,
              ),
            ),
            const SizedBox(width: 8),
            _buildMetricChip(
              l10n.controllersOnline,
              '${dashState.controllersOnlineCount}/${dashState.controllers.length}',
              dashState.controllersOnlineCount == dashState.controllers.length ? LedColor.green : LedColor.orange,
              true,
              const Color(0xFF2196F3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, LedColor ledColor, bool isOn, Color accent, {bool pulse = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2137),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LedIndicator(isOn: isOn, activeColor: ledColor, size: 10, animate: pulse),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accent)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white60), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildControllerCards(AppLocalizations l10n, ControllersState controllersState, DashboardState dashState) {
    if (controllersState.controllers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(l10n.projectControllers),
          const SizedBox(height: 8),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controllersState.controllers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final c = controllersState.controllers[index];
                final isIrrigating = dashState.irrigatingStatus['${c.id}.Irrigating'] ?? false;
                final hasAlarm = dashState.activeAlarms > 0;
                return _controllerCard(l10n, c.id, c.displayName, c.tagCount, isIrrigating, hasAlarm);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _controllerCard(AppLocalizations l10n, String id, String name, int tags, bool irrigating, bool hasAlarm) {
    return GestureDetector(
      onTap: () => context.go('/controllers/$id'),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2137),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: irrigating ? const Color(0xFF00E676).withOpacity(0.3) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF156082).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.memory, size: 14, color: Color(0xFF156082)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(name, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.5)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LedRow(
              ledSize: 10,
              items: [
                LedItem(isOn: true, color: LedColor.green, label: l10n.online),
                LedItem(isOn: irrigating, color: LedColor.green, label: l10n.irrigating),
                LedItem(isOn: hasAlarm, color: LedColor.red, label: l10n.alarms),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.flowRateLabel, style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.4))),
                    Text('${tags}', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                  ],
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowMetersSection(AppLocalizations l10n, DashboardState dashState) {
    final sensors = dashState.flowSensors;
    if (sensors.isEmpty) return const SizedBox.shrink();

    final sensorList = sensors.entries.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed, size: 16, color: Color(0xFF00E676)),
              const SizedBox(width: 6),
              _sectionHeader(l10n.flowMeters),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${l10n.totalFlow}: ${dashState.totalFlowRate.toStringAsFixed(1)} L/min',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF00E676), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.4,
            ),
            itemCount: sensorList.length,
            itemBuilder: (context, index) {
              final entry = sensorList[index];
              final displayName = entry.key.split('.').skip(1).join('.');
              return FlowMeterWidget(
                label: displayName,
                value: entry.value.value,
                unit: entry.value.unit,
                status: entry.value.status,
                trendData: entry.value.history,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n) {
    final actions = [
      _ActionItem(Icons.medical_information, l10n.diagnostics, '/diagnostics'),
      _ActionItem(Icons.play_circle, l10n.operationCommands, '/operation-commands'),
      _ActionItem(Icons.info, l10n.operationStatus, '/operation-status'),
      _ActionItem(Icons.map, l10n.map, '/map'),
      _ActionItem(Icons.schedule, l10n.schedules, '/schedules'),
      _ActionItem(Icons.assessment, l10n.reports, '/reports'),
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(l10n.quickActions),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _quickActionCard(action, () => context.go(action.route));
            },
          ),
        ],
      ),
    );
  }

  Widget _quickActionCard(_ActionItem action, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF156082).withOpacity(0.15),
              const Color(0xFF0D2137),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF156082).withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: const Color(0xFF156082), size: 24),
            const SizedBox(height: 6),
            Text(action.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white70), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlarms(AppLocalizations l10n, AlarmsState alarmsState) {
    if (alarmsState.alarms.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, size: 16, color: Color(0xFFFF9800)),
              const SizedBox(width: 6),
              _sectionHeader('${l10n.recentAlarms} (${alarmsState.alarms.length})'),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go('/alarms'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF156082).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(l10n.viewAll, style: const TextStyle(fontSize: 11, color: Color(0xFF156082), fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...alarmsState.alarms.take(5).map((a) => _alarmTile(l10n, a)),
        ],
      ),
    );
  }

  Widget _alarmTile(AppLocalizations l10n, AlarmEntity a) {
    final color = a.priority >= 4 ? const Color(0xFFF44336) : a.priority >= 2 ? const Color(0xFFFF9800) : const Color(0xFFFFC107);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2137),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.alarmComment.isNotEmpty ? a.alarmComment : a.tagName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                Text(
                  '${a.userDef3.isNotEmpty ? a.userDef3 : a.tagGroup} - ${a.alarmTime}',
                  style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('P${a.priority}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white));
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final String route;
  const _ActionItem(this.icon, this.label, this.route);
}
