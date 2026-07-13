import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';
import 'package:hunter360_app/features/alarms/presentation/providers/alarms_provider.dart';
import '../providers/controllers_provider.dart';

class ControllerDetailPage extends ConsumerStatefulWidget {
  final String controllerId;
  const ControllerDetailPage({super.key, required this.controllerId});

  @override
  ConsumerState<ControllerDetailPage> createState() => _ControllerDetailPageState();
}

class _ControllerDetailPageState extends ConsumerState<ControllerDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    Future.microtask(() {
      ref.read(controllersProvider.notifier).loadStationsForController(widget.controllerId);
      _subscribeToRealtime();
    });
  }

  void _subscribeToRealtime() {
    final realtimeService = ref.read(realtimeServiceProvider);
    final state = ref.read(controllersProvider);
    final tagNames = state.valves.map((v) => v.id).toList();

    final infoTags = [
      '${widget.controllerId}.ControllerInfo.FirmwareVersion',
      '${widget.controllerId}.ControllerInfo.IP',
      '${widget.controllerId}.ControllerInfo.DateTime',
      '${widget.controllerId}.ControllerInfo.MasterMode',
      '${widget.controllerId}.Status',
      '${widget.controllerId}.Module1.CurrentDraw',
      '${widget.controllerId}.Module1.Overload',
      '${widget.controllerId}.Module1.PathStatus',
      '${widget.controllerId}.Module2.CurrentDraw',
      '${widget.controllerId}.Module2.Overload',
      '${widget.controllerId}.Module2.PathStatus',
      '${widget.controllerId}.Module3.CurrentDraw',
      '${widget.controllerId}.Module3.Overload',
      '${widget.controllerId}.Module3.PathStatus',
      '${widget.controllerId}.System.Irrigating',
      '${widget.controllerId}.System.Shutdown',
      '${widget.controllerId}.System.DaysOff',
      '${widget.controllerId}.System.Suspend',
      '${widget.controllerId}.System.Mute',
      '${widget.controllerId}.Comm.Quality',
      '${widget.controllerId}.Comm.LastOK',
      '${widget.controllerId}.Comm.Retries',
    ];
    realtimeService.subscribe([...tagNames, ...infoTags]);
    realtimeService.start();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(controllersProvider);
    final realtimeService = ref.watch(realtimeServiceProvider);

    final project = AppConstants.controllers.firstWhere(
      (c) => c['id'] == widget.controllerId,
      orElse: () => {'id': widget.controllerId, 'name': widget.controllerId},
    );
    final projectName = project['name'] ?? widget.controllerId;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.controllerId}-$projectName'),
        backgroundColor: const Color(0xFF156082),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(controllersProvider.notifier).loadStationsForController(widget.controllerId);
              _subscribeToRealtime();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.stationsTab),
            Tab(text: l10n.blocksTab),
            Tab(text: l10n.alarmsTab),
            Tab(text: l10n.manualTab),
            Tab(text: l10n.infoTab),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF156082)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStationsTab(l10n, state, realtimeService),
                _buildBlocksTab(l10n, state, realtimeService),
                _buildAlarmsTab(l10n),
                _buildManualTab(l10n, state),
                _buildInfoTab(l10n, state, realtimeService),
              ],
            ),
    );
  }

  Widget _buildStationsTab(AppLocalizations l10n, ControllersState state, RealtimeService realtimeService) {
    if (state.valves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(l10n.noStationsFound, style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return StreamBuilder<Map<String, TagValue>>(
      stream: realtimeService.tagValuesStream,
      builder: (context, snapshot) {
        final liveData = snapshot.data ?? realtimeService.currentValues;
        final openCount = state.valves.where((v) {
          final val = double.tryParse(liveData[v.id]?.scaledValue ?? '') ?? 0;
          return val > 0;
        }).length;

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(controllersProvider.notifier).loadStationsForController(widget.controllerId);
            _subscribeToRealtime();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusHeader(l10n, state.valves.length, openCount),
              const SizedBox(height: 16),
              ...state.valves.map((valve) {
                final liveValue = liveData[valve.id]?.scaledValue ?? '';
                final liveFlow = double.tryParse(liveValue) ?? 0;
                final isRunning = liveFlow > 0;
                return _stationCard(l10n, valve, liveFlow, isRunning);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusHeader(AppLocalizations l10n, int total, int open) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3B4F), Color(0xFF156082)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF156082).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.controllerStatusLabel, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusItem(Icons.play_circle_outline, '$open', l10n.openStationsLabel),
              _statusItem(Icons.pause_circle_outline, '${total - open}', l10n.closedStationsLabel),
              _statusItem(Icons.grid_view, '$total', l10n.totalStationsLabel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _stationCard(AppLocalizations l10n, valve, double flowRate, bool isRunning) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isRunning ? Colors.blue.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.water_drop, color: isRunning ? Colors.blue : Colors.grey, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.station} ${valve.stationNumber}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(valve.name, style: TextStyle(fontSize: 12, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isRunning ? '${flowRate.toStringAsFixed(1)} ${l10n.litersPerMinute}' : l10n.closed,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isRunning ? Colors.blue : Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isRunning ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isRunning ? l10n.irrigating : l10n.notIrrigating,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isRunning ? Colors.blue.shade700 : Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlocksTab(AppLocalizations l10n, ControllersState state, RealtimeService realtimeService) {
    if (state.valves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.view_agenda_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(l10n.noBlocksFound, style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    final grouped = <String, List<dynamic>>{};
    for (final valve in state.valves) {
      final parts = valve.name.split('.');
      final blockName = parts.length > 1 ? parts[0] : l10n.blocksTab;
      grouped.putIfAbsent(blockName, () => []).add(valve);
    }

    return StreamBuilder<Map<String, TagValue>>(
      stream: realtimeService.tagValuesStream,
      builder: (context, snapshot) {
        final liveData = snapshot.data ?? realtimeService.currentValues;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: grouped.entries.map((entry) {
            final openInBlock = entry.value.where((v) {
              final val = double.tryParse(liveData[v.id]?.scaledValue ?? '') ?? 0;
              return val > 0;
            }).length;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: const Color(0xFF156082).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.view_agenda, color: Color(0xFF156082), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('${entry.value.length} ${l10n.station.toLowerCase()}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        Text(
                          '$openInBlock/${entry.value.length}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: openInBlock > 0 ? Colors.blue : Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...entry.value.map((valve) {
                      final liveValue = liveData[valve.id]?.scaledValue ?? '';
                      final liveFlow = double.tryParse(liveValue) ?? 0;
                      final isRunning = liveFlow > 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: isRunning ? Colors.blue : Colors.grey.shade300, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('${l10n.station} ${valve.stationNumber} - ${valve.name}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ),
                            Text(
                              isRunning ? l10n.open : l10n.closed,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isRunning ? Colors.blue : Colors.grey.shade400),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAlarmsTab(AppLocalizations l10n) {
    final alarmsState = ref.watch(alarmsProvider);

    if (alarmsState.alarms.isEmpty && !alarmsState.isLoading && alarmsState.error == null) {
      Future.microtask(() {
        ref.read(alarmsProvider.notifier).loadAlarms();
        ref.read(alarmsProvider.notifier).setControllerFilter(widget.controllerId);
      });
    }

    final controllerAlarms = alarmsState.filteredAlarms;

    if (alarmsState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF156082)));
    }

    if (alarmsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade200),
            const SizedBox(height: 16),
            Text(l10n.error, style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () => ref.read(alarmsProvider.notifier).loadAlarms(), child: Text(l10n.retry)),
          ],
        ),
      );
    }

    if (controllerAlarms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 80, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text(l10n.noAlarms, style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            Text('${l10n.alarmsTab} - ${widget.controllerId}', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(alarmsProvider.notifier).loadAlarms(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controllerAlarms.length,
        itemBuilder: (context, index) {
          final alarm = controllerAlarms[index];
          final priorityColor = alarm.isCritical ? Colors.red : alarm.isWarning ? Colors.orange : Colors.blue;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Icon(Icons.warning_amber_rounded, color: priorityColor, size: 28),
              title: Text(alarm.alarmComment.isNotEmpty ? alarm.alarmComment : alarm.tagName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('${alarm.alarmTime}  •  ${alarm.alarmType}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              trailing: alarm.isAcknowledged
                  ? Icon(Icons.check_circle, color: Colors.green.shade400, size: 20)
                  : Icon(Icons.error, color: priorityColor, size: 20),
            ),
          );
        },
      ),
    );
  }

  Widget _buildManualTab(AppLocalizations l10n, ControllersState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.settings, color: Color(0xFF156082)),
                      const SizedBox(width: 8),
                      Text(l10n.manualOperation, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmAndSendCommand(l10n.start, '1'),
                          icon: const Icon(Icons.play_arrow, size: 20),
                          label: Text(l10n.start),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmAndSendCommand(l10n.stop, '0'),
                          icon: const Icon(Icons.stop, size: 20),
                          label: Text(l10n.stop),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.controllerInfo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _infoRow(l10n.controllerId, widget.controllerId),
                  const Divider(),
                  _infoRow(l10n.projectLabel, AppConstants.controllers.firstWhere(
                    (c) => c['id'] == widget.controllerId,
                    orElse: () => {'name': widget.controllerId},
                  )['name'] ?? widget.controllerId),
                  const Divider(),
                  _infoRow(l10n.status, l10n.online),
                  const Divider(),
                  _infoRow(l10n.tagsCount, '${state.valves.length + state.blockTags.length}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _confirmAndSendCommand(String actionLabel, String value) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirm),
        content: Text('$actionLabel ${widget.controllerId}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.confirm)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final apiClient = ref.read(apiClientProvider);
    try {
      final tag = '${widget.controllerId}.StartSingleManualEvent_DeviceType_Command';
      await apiClient.post(
        ApiConstants.tagsWrite,
        data: [{'TagName': tag, 'RawValue': value}],
        contentType: 'application/json',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.commandSent}: $actionLabel'), backgroundColor: const Color(0xFF4CAF50)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- NEW: Info Tab ---
  Widget _buildInfoTab(AppLocalizations l10n, ControllersState state, RealtimeService realtimeService) {
    final prefix = widget.controllerId;
    final isACC2 = widget.controllerId == 'C001' || widget.controllerId == 'C002' || widget.controllerId == 'C003';

    return StreamBuilder<Map<String, TagValue>>(
      stream: realtimeService.tagValuesStream,
      builder: (context, snapshot) {
        final liveData = snapshot.data ?? realtimeService.currentValues;

        final firmware = liveData['$prefix.ControllerInfo.FirmwareVersion']?.scaledValue ?? '-';
        final ip = liveData['$prefix.ControllerInfo.IP']?.scaledValue ?? '-';
        final dateTime = liveData['$prefix.ControllerInfo.DateTime']?.scaledValue ?? '-';
        final masterMode = liveData['$prefix.ControllerInfo.MasterMode']?.scaledValue ?? '-';
        final isOnline = liveData['$prefix.Status']?.scaledValue?.toLowerCase() != 'offline' &&
            (liveData['$prefix.Status']?.scaledValue ?? '').isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildControllerInfoSection(l10n, firmware, ip, dateTime, masterMode, isOnline, isACC2, state),
              const SizedBox(height: 16),
              _buildModuleInfoSection(l10n, realtimeService),
              const SizedBox(height: 16),
              _buildSystemStatusSection(l10n, realtimeService),
              const SizedBox(height: 16),
              _buildConnectionStatsSection(l10n, realtimeService),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControllerInfoSection(AppLocalizations l10n, String firmware, String ip, String dateTime, String masterMode, bool isOnline, bool isACC2, ControllersState state) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF156082)),
                const SizedBox(width: 8),
                Text(l10n.controllerInfo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: isOnline ? const Color(0xFF4CAF50) : Colors.red, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(isOnline ? l10n.online : l10n.offline, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isOnline ? const Color(0xFF4CAF50) : Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(l10n.controllerTypeLabel, isACC2 ? 'ACC2' : 'ACC1'),
            const Divider(),
            _infoRow(l10n.firmwareVersion, firmware),
            const Divider(),
            _infoRow(l10n.stationSize, '${state.valves.length}'),
            const Divider(),
            _infoRow(l10n.currentDateTime, dateTime),
            const Divider(),
            _infoRow(l10n.ipAddress, ip),
            const Divider(),
            _infoRow(l10n.communicationProtocol, 'TCP/IP'),
            const Divider(),
            _infoRow(l10n.masterSlaveMode, masterMode),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleInfoSection(AppLocalizations l10n, RealtimeService realtimeService) {
    final prefix = widget.controllerId;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.developer_board, color: Color(0xFF156082)),
                const SizedBox(width: 8),
                Text(l10n.moduleInformation, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(3, (i) {
              final moduleNum = i + 1;
              final currentDraw = realtimeService.getValue('$prefix.Module$moduleNum.CurrentDraw');
              final overload = realtimeService.getValue('$prefix.Module$moduleNum.Overload');
              final pathStatus = realtimeService.getValue('$prefix.Module$moduleNum.PathStatus');

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l10n.module} $moduleNum', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                      const SizedBox(height: 8),
                      _infoRow(l10n.currentDraw, currentDraw.isNotEmpty ? '$currentDraw A' : '-'),
                      const SizedBox(height: 4),
                      _infoRow(l10n.overloadStatus, overload.isNotEmpty ? (overload == '1' ? l10n.critical : l10n.normalLabel) : l10n.normalLabel),
                      const SizedBox(height: 4),
                      _infoRow(l10n.pathStatus, pathStatus.isNotEmpty ? (pathStatus == '1' ? l10n.activeLabel : l10n.normalLabel) : l10n.noneLabel),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusSection(AppLocalizations l10n, RealtimeService realtimeService) {
    final prefix = widget.controllerId;

    final irrigating = realtimeService.getValue('$prefix.System.Irrigating');
    final shutdown = realtimeService.getValue('$prefix.System.Shutdown');
    final daysOff = realtimeService.getValue('$prefix.System.DaysOff');
    final suspend = realtimeService.getValue('$prefix.System.Suspend');
    final mute = realtimeService.getValue('$prefix.System.Mute');

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monitor_heart, color: Color(0xFF156082)),
                const SizedBox(width: 8),
                Text(l10n.systemStatus, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _systemStatusRow(l10n.irrigatingStatus, irrigating, l10n),
            const Divider(),
            _systemStatusRow(l10n.shutdownStatus, shutdown, l10n),
            const Divider(),
            _systemStatusRow(l10n.daysOffStatus, daysOff, l10n),
            const Divider(),
            _systemStatusRow(l10n.suspendStatus, suspend, l10n),
            const Divider(),
            _systemStatusRow(l10n.muteStatus, mute, l10n),
          ],
        ),
      ),
    );
  }

  Widget _systemStatusRow(String label, String value, AppLocalizations l10n) {
    final isActive = value == '1' || value.toLowerCase() == 'true';
    final displayValue = value.isEmpty ? '-' : (isActive ? l10n.activeLabel : l10n.normalLabel);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.orange.withOpacity(0.1)
                  : const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.orange.shade700 : const Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatsSection(AppLocalizations l10n, RealtimeService realtimeService) {
    final prefix = widget.controllerId;

    final quality = realtimeService.getValue('$prefix.Comm.Quality');
    final lastOK = realtimeService.getValue('$prefix.Comm.LastOK');
    final retries = realtimeService.getValue('$prefix.Comm.Retries');

    final qualityPercent = double.tryParse(quality) ?? 0;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wifi, color: Color(0xFF156082)),
                const SizedBox(width: 8),
                Text(l10n.connectionStatistics, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(l10n.communicationQuality, quality.isNotEmpty ? '${qualityPercent.toStringAsFixed(1)}%' : '-'),
            const SizedBox(height: 12),
            if (qualityPercent > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: qualityPercent / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    qualityPercent > 80 ? const Color(0xFF4CAF50) : (qualityPercent > 50 ? Colors.orange : Colors.red),
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
            ],
            const Divider(),
            _infoRow(l10n.lastCommunication, lastOK.isNotEmpty ? lastOK : '-'),
            const Divider(),
            _infoRow(l10n.retryCount, retries.isNotEmpty ? retries : '0'),
          ],
        ),
      ),
    );
  }
}
