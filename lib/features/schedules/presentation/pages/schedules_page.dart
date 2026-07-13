import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import '../providers/schedules_provider.dart';

class SchedulesPage extends ConsumerStatefulWidget {
  const SchedulesPage({super.key});

  @override
  ConsumerState<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends ConsumerState<SchedulesPage> {
  String _selectedController = '';
  double _seasonalAdjustment = 100.0;

  @override
  void initState() {
    super.initState();
    if (AppConstants.controllers.isNotEmpty) {
      _selectedController = AppConstants.controllers.first['id']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final schedulesState = ref.watch(schedulesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF156082),
        title: Text(
          localizations.schedules,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              ref.read(schedulesProvider.notifier).loadSchedules(_selectedController);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControllerSelector(localizations),
          _buildHeaderBar(localizations),
          Expanded(
            child: schedulesState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF156082),
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(localizations.errorLoadingData),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(schedulesProvider.notifier).loadSchedules(_selectedController);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF156082),
                      ),
                      child: Text(localizations.retry),
                    ),
                  ],
                ),
              ),
              data: (schedules) => RefreshIndicator(
                onRefresh: () async {
                  await ref.read(schedulesProvider.notifier).loadSchedules(_selectedController);
                },
                color: const Color(0xFF156082),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSeasonalAdjustmentCard(localizations),
                    const SizedBox(height: 16),
                    ...schedules.map((schedule) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildScheduleCard(schedule, localizations),
                    )),
                    if (schedules.isEmpty) _buildEmptyState(localizations),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF156082),
        onPressed: () => _showAddProgramDialog(localizations),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildControllerSelector(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Icon(Icons.device_hub, color: const Color(0xFF156082), size: 20),
          const SizedBox(width: 8),
          Text(
            localizations.controller,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedController.isNotEmpty ? _selectedController : null,
                  hint: Text(localizations.selectController),
                  items: AppConstants.controllers.map((c) {
                    return DropdownMenuItem(
                      value: c['id']!,
                      child: Text('${c['id']} - ${c['name']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedController = value;
                      });
                      ref.read(schedulesProvider.notifier).loadSchedules(value);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBar(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF156082), Color(0xFF1A7A9E)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  localizations.projectName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              localizations.online,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalAdjustmentCard(AppLocalizations localizations) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny, color: Color(0xFFFF9800), size: 22),
                const SizedBox(width: 8),
                Text(
                  localizations.seasonalAdjustment,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF156082).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_seasonalAdjustment.toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF156082),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF156082),
                inactiveTrackColor: const Color(0xFFE0E0E0),
                thumbColor: const Color(0xFF156082),
                overlayColor: const Color(0xFF156082).withOpacity(0.2),
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              ),
              child: Slider(
                value: _seasonalAdjustment,
                min: 0,
                max: 200,
                divisions: 40,
                onChanged: (value) {
                  setState(() {
                    _seasonalAdjustment = value;
                  });
                },
                onChangeEnd: (value) {
                  ref.read(schedulesProvider.notifier).updateSeasonalAdjustment(
                    _selectedController,
                    value,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.minimum,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  localizations.recommended100,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  localizations.maximum,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(dynamic schedule, AppLocalizations localizations) {
    final isExpanded = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isExpanded,
      builder: (context, expanded, _) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: schedule.enabled
                    ? const Color(0xFF4CAF50).withOpacity(0.3)
                    : const Color(0xFFE0E0E0),
              ),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => isExpanded.value = !expanded,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: schedule.enabled
                                ? const Color(0xFF4CAF50).withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${schedule.programNumber}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: schedule.enabled
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                schedule.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildInfoChip(Icons.access_time, schedule.startTime),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(Icons.timer, schedule.runTime),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: schedule.enabled,
                          activeColor: const Color(0xFF4CAF50),
                          onChanged: (value) {
                            ref.read(schedulesProvider.notifier).toggleSchedule(schedule.id);
                          },
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                if (expanded) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.daysOfWeek,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDaysOfWeek(schedule.daysOfWeek, localizations),
                        const SizedBox(height: 16),
                        Text(
                          localizations.blocks,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...schedule.blocks.map<Widget>((block) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.square, size: 16, color: Color(0xFF156082)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    block.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  block.runTime,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, size: 18),
                              label: Text(localizations.edit),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.copy, size: 18, color: Color(0xFF2196F3)),
                              label: Text(
                                localizations.duplicate,
                                style: const TextStyle(color: Color(0xFF2196F3)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek(List<bool> days, AppLocalizations localizations) {
    final dayLabels = [
      localizations.saturday,
      localizations.sunday,
      localizations.monday,
      localizations.tuesday,
      localizations.wednesday,
      localizations.thursday,
      localizations.friday,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final isActive = index < days.length ? days[index] : false;
        return Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF156082)
                    : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  dayLabels[index][0],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayLabels[index].substring(0, 3),
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            localizations.noPrograms,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.tapToAddProgram,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProgramDialog(AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.addProgram),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: localizations.programName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: localizations.startTime,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF156082),
            ),
            child: Text(localizations.add),
          ),
        ],
      ),
    );
  }
}