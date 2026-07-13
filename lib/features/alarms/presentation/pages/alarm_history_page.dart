import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import '../providers/alarm_history_provider.dart';

class AlarmHistoryPage extends ConsumerStatefulWidget {
  const AlarmHistoryPage({super.key});

  @override
  ConsumerState<AlarmHistoryPage> createState() => _AlarmHistoryPageState();
}

class _AlarmHistoryPageState extends ConsumerState<AlarmHistoryPage> {
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final defaultStart = now.subtract(const Duration(days: 7));
    ref.read(alarmHistoryProvider.notifier).setStartDate(defaultStart);
    ref.read(alarmHistoryProvider.notifier).setEndDate(now);
    Future.microtask(() => ref.read(alarmHistoryProvider.notifier).loadAlarms());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alarmHistoryProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(l10n, state),
          _buildDateRange(l10n, state),
          _buildFilters(l10n, state),
          _buildStatsBar(l10n, state),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF156082)))
                : state.error != null
                    ? _buildErrorState(l10n)
                    : state.filteredAlarms.isEmpty
                        ? _buildEmptyState(l10n)
                        : _buildAlarmList(l10n, state),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, AlarmHistoryState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0D3B4F), Color(0xFF156082)]),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.history, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.alarmHistoryTitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  '${state.filteredAlarms.length} / ${state.totalCount}',
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _exportCsv(state, l10n),
            icon: const Icon(Icons.download, color: Colors.white, size: 22),
            tooltip: l10n.exportCSV,
          ),
        ],
      ),
    );
  }

  Widget _buildDateRange(AppLocalizations l10n, AlarmHistoryState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Expanded(child: _buildDateChip(l10n.fromLabel, state.startDate, isStart: true)),
          const SizedBox(width: 10),
          Expanded(child: _buildDateChip(l10n.toLabel, state.endDate, isStart: false)),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, DateTime? date, {required bool isStart}) {
    final formatted = date != null ? DateFormat('yyyy-MM-dd').format(date) : '---';
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          final notifier = ref.read(alarmHistoryProvider.notifier);
          if (isStart) {
            notifier.setStartDate(picked);
          } else {
            notifier.setEndDate(picked);
          }
          notifier.loadAlarms();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                Text(formatted, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n, AlarmHistoryState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: state.controllerFilter.isEmpty ? null : state.controllerFilter,
                      hint: Text(l10n.allControllers, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 18),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('All')),
                        ...AppConstants.controllers.map((c) => DropdownMenuItem(
                              value: c['id'],
                              child: Text('${c['id']} - ${c['name']}'),
                            )),
                      ],
                      onChanged: (v) {
                        ref.read(alarmHistoryProvider.notifier).setControllerFilter(v ?? '');
                        ref.read(alarmHistoryProvider.notifier).loadAlarms();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _priorityChip(l10n.all, HistoryPriorityFilter.all, state),
              const SizedBox(width: 6),
              _priorityChip(l10n.critical, HistoryPriorityFilter.critical, state),
              const SizedBox(width: 6),
              _priorityChip(l10n.warning, HistoryPriorityFilter.warning, state),
              const SizedBox(width: 6),
              _priorityChip(l10n.info, HistoryPriorityFilter.info, state),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priorityChip(String label, HistoryPriorityFilter filter, AlarmHistoryState state) {
    final isSelected = state.priorityFilter == filter;
    final color = filter == HistoryPriorityFilter.critical
        ? Colors.red
        : filter == HistoryPriorityFilter.warning
            ? Colors.orange
            : filter == HistoryPriorityFilter.info
                ? Colors.blue
                : const Color(0xFF156082);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(alarmHistoryProvider.notifier).setPriorityFilter(filter);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? color : Colors.grey.shade500),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar(AppLocalizations l10n, AlarmHistoryState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.totalInPeriod, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF156082))),
          const SizedBox(height: 8),
          Row(
            children: [
              _statItem('${state.totalCount}', l10n.all, const Color(0xFF156082)),
              _statItem('${state.criticalCount}', l10n.critical, Colors.red),
              _statItem('${state.warningCount}', l10n.warning, Colors.orange),
              _statItem('${state.infoCount}', l10n.info, Colors.blue),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.pie_chart_outline, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${l10n.mostCommonAlarm}: ${state.mostCommonAlarmType}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String count, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildAlarmList(AppLocalizations l10n, AlarmHistoryState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(alarmHistoryProvider.notifier).loadAlarms(),
      color: const Color(0xFF156082),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: state.filteredAlarms.length,
        itemBuilder: (context, index) => _buildAlarmCard(state.filteredAlarms[index], l10n),
      ),
    );
  }

  Widget _buildAlarmCard(HistoricalAlarm alarm, AppLocalizations l10n) {
    final pColor = alarm.priorityColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: pColor.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: pColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: pColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text('P${alarm.priority}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: pColor)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alarm.alarmComment.isNotEmpty ? alarm.alarmComment : alarm.tagName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF212121)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _infoRow(Icons.tag, alarm.tagName.isNotEmpty ? alarm.tagName : '-'),
                    const SizedBox(height: 3),
                    _infoRow(Icons.settings_input_antenna,
                        alarm.userDef3.isNotEmpty ? '${alarm.tagGroup} - ${alarm.userDef3}' : alarm.tagGroup),
                    const SizedBox(height: 3),
                    _infoRow(Icons.access_time, alarm.alarmTime.isNotEmpty ? alarm.alarmTime : '-'),
                    if (alarm.alarmType.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      _infoRow(Icons.category, alarm.alarmType),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          alarm.isAcknowledged ? Icons.check_circle : Icons.cancel,
                          size: 13,
                          color: alarm.isAcknowledged ? Colors.green : Colors.red.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alarm.isAcknowledged ? l10n.acknowledged : l10n.unacknowledged,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: alarm.isAcknowledged ? Colors.green.shade700 : Colors.red.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Expanded(child: Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF156082).withOpacity(0.06), shape: BoxShape.circle),
              child: Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
            ),
            const SizedBox(height: 16),
            Text(l10n.noDataInPeriod, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(l10n.error, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => ref.read(alarmHistoryProvider.notifier).loadAlarms(),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF156082),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportCsv(AlarmHistoryState state, AppLocalizations l10n) {
    final buffer = StringBuffer();
    buffer.writeln('DateTime,TagName,AlarmType,Priority,Comment,AckStatus,Controller');
    for (final a in state.filteredAlarms) {
      final row = [
        a.alarmTime,
        a.tagName,
        a.alarmType,
        '${a.priority}',
        '"${a.alarmComment.replaceAll('"', '""')}"',
        a.isAcknowledged ? 'Acked' : 'Unacked',
        a.tagGroup,
      ].join(',');
      buffer.writeln(row);
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.exportCSV),
        content: Text('${state.filteredAlarms.length} alarms ready to export'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
        ],
      ),
    );
  }
}
