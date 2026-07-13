import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';
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
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() {
      ref.read(controllersProvider.notifier).loadStationsForController(widget.controllerId);
      _subscribeToRealtime();
    });
  }

  void _subscribeToRealtime() {
    final realtimeService = ref.read(realtimeServiceProvider);
    final state = ref.read(controllersProvider);
    final tagNames = state.valves.map((v) => v.id).toList();
    realtimeService.subscribe(tagNames);
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
          tabs: [
            Tab(text: l10n.stationsTab),
            Tab(text: l10n.blocksTab),
            Tab(text: l10n.alarmsTab),
            Tab(text: l10n.manualTab),
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
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
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
              child: Icon(
                Icons.water_drop,
                color: isRunning ? Colors.blue : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.station} ${valve.stationNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valve.name,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isRunning ? '${flowRate.toStringAsFixed(1)} ${l10n.litersPerMinute}' : l10n.closed,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isRunning ? Colors.blue : Colors.grey.shade500,
                  ),
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
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isRunning ? Colors.blue.shade700 : Colors.grey.shade500,
                    ),
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF156082).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.view_agenda, color: Color(0xFF156082), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                '${entry.value.length} ${l10n.station.toLowerCase()}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$openInBlock/${entry.value.length}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: openInBlock > 0 ? Colors.blue : Colors.grey.shade500,
                          ),
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
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isRunning ? Colors.blue : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${l10n.station} ${valve.stationNumber} - ${valve.name}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ),
                            Text(
                              isRunning ? l10n.open : l10n.closed,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isRunning ? Colors.blue : Colors.grey.shade400,
                              ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            l10n.noAlarms,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.alarmsTab} - ${widget.controllerId}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
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
                      Text(
                        l10n.manualOperation,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${l10n.commandSent}: ${l10n.start}'), backgroundColor: const Color(0xFF4CAF50)),
                            );
                          },
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${l10n.commandSent}: ${l10n.stop}'), backgroundColor: Colors.red),
                            );
                          },
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
                  Text(
                    l10n.controllerInfo,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
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
}
