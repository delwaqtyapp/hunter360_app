import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                child: CircularProgressIndicator(color: Color(0xFF156082)),
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
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF156082)),
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
          Text(localizations.controller,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
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
                    return DropdownMenuItem(value: c['id']!, child: Text('${c['id']} - ${c['name']}'));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedController = value);
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
                Text(_selectedController,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                Text(localizations.projectName,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(localizations.online,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
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
                Text(localizations.seasonalAdjustment,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF156082).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${_seasonalAdjustment.toInt()}%',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF156082))),
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
                onChanged: (value) => setState(() => _seasonalAdjustment = value),
                onChangeEnd: (value) {
                  ref.read(schedulesProvider.notifier).updateSeasonalAdjustment(_selectedController, value);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localizations.minimum, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(localizations.recommended100, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(localizations.maximum, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleEntity schedule, AppLocalizations localizations) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: schedule.enabled ? const Color(0xFF4CAF50).withOpacity(0.3) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.all(16),
            leading: Container(
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
                    color: schedule.enabled ? const Color(0xFF4CAF50) : Colors.grey,
                  ),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schedule.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip(Icons.access_time, schedule.startTime),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.timer, schedule.runTime),
                    const SizedBox(width: 8),
                    _buildModeChip(schedule, localizations),
                  ],
                ),
              ],
            ),
            trailing: Switch(
              value: schedule.enabled,
              activeColor: const Color(0xFF4CAF50),
              onChanged: (_) {
                ref.read(schedulesProvider.notifier).toggleSchedule(schedule.id);
              },
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScheduleTypeSelector(schedule, localizations),
                  const SizedBox(height: 16),
                  if (schedule.scheduleType == ScheduleType.weekly) ...[
                    Text(localizations.daysOfWeek,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                    const SizedBox(height: 8),
                    _buildDaysOfWeekToggle(schedule, localizations),
                    const SizedBox(height: 16),
                  ],
                  if (schedule.scheduleType == ScheduleType.oddEven) ...[
                    _buildOddEvenSelector(schedule, localizations),
                    const SizedBox(height: 16),
                  ],
                  if (schedule.scheduleType == ScheduleType.interval) ...[
                    _buildIntervalSelector(schedule, localizations),
                    const SizedBox(height: 16),
                  ],
                  _buildProgramModeToggle(schedule, localizations),
                  const SizedBox(height: 16),
                  _buildNoWaterWindow(schedule, localizations),
                  const SizedBox(height: 16),
                  _buildStationDelaySection(schedule, localizations),
                  const SizedBox(height: 16),
                  _buildStackOverlapSelector(schedule, localizations),
                  const SizedBox(height: 16),
                  _buildStartTimesSection(schedule, localizations),
                  const SizedBox(height: 16),
                  _buildRunTimesSection(schedule, localizations),
                  const SizedBox(height: 16),
                  Text(localizations.blocks,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                  const SizedBox(height: 8),
                  ...schedule.blocks.map<Widget>((block) => _buildBlockTile(block, schedule, localizations)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/schedules/editor', arguments: schedule.id);
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: Text(localizations.edit),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.copy, size: 18, color: Color(0xFF2196F3)),
                        label: Text(localizations.duplicate, style: const TextStyle(color: Color(0xFF2196F3))),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeChip(ScheduleEntity schedule, AppLocalizations localizations) {
    final isAuto = schedule.programAutoMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isAuto ? const Color(0xFF4CAF50).withOpacity(0.1) : const Color(0xFFFF9800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAuto ? Icons.autorenew : Icons.touch_app,
            size: 10,
            color: isAuto ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
          ),
          const SizedBox(width: 2),
          Text(
            isAuto ? localizations.autoMode : localizations.manualMode,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isAuto ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTypeSelector(ScheduleEntity schedule, AppLocalizations localizations) {
    final types = [
      (ScheduleType.weekly, localizations.weeklySchedule, Icons.view_week),
      (ScheduleType.oddEven, localizations.oddEvenSchedule, Icons.date_range),
      (ScheduleType.interval, localizations.intervalSchedule, Icons.event_repeat),
      (ScheduleType.manual, localizations.manualSchedule, Icons.touch_app),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.scheduleType,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
        const SizedBox(height: 8),
        Row(
          children: types.map((type) {
            final isSelected = schedule.scheduleType == type.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(schedulesProvider.notifier).updateScheduleType(schedule.id, type.$1);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF156082) : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF156082) : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(type.$3,
                          size: 18,
                          color: isSelected ? Colors.white : Colors.grey[600]),
                      const SizedBox(height: 4),
                      Text(
                        type.$2,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDaysOfWeekToggle(ScheduleEntity schedule, AppLocalizations localizations) {
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
        final isActive = index < schedule.daysOfWeek.length && schedule.daysOfWeek[index];
        return GestureDetector(
          onTap: () {
            ref.read(schedulesProvider.notifier).toggleDayOfWeek(schedule.id, index);
          },
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF156082) : const Color(0xFFF5F7FA),
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
              Text(dayLabels[index].substring(0, 3),
                  style: TextStyle(fontSize: 9, color: Colors.grey[600])),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOddEvenSelector(ScheduleEntity schedule, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.oddEvenSchedule,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildRadioOption(
                label: localizations.oddDays,
                value: OddEvenMode.odd,
                groupValue: schedule.oddEvenMode,
                onChanged: (v) => ref.read(schedulesProvider.notifier).updateOddEvenMode(schedule.id, v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRadioOption(
                label: localizations.evenDays,
                value: OddEvenMode.even,
                groupValue: schedule.oddEvenMode,
                onChanged: (v) => ref.read(schedulesProvider.notifier).updateOddEvenMode(schedule.id, v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRadioOption(
                label: localizations.bothOddEven,
                value: OddEvenMode.both,
                groupValue: schedule.oddEvenMode,
                onChanged: (v) => ref.read(schedulesProvider.notifier).updateOddEvenMode(schedule.id, v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption<T>({
    required String label,
    required T value,
    required T groupValue,
    required ValueChanged<T> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF156082).withOpacity(0.1) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF156082) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF156082) : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalSelector(ScheduleEntity schedule, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.intervalDays,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (schedule.intervalDays > 1) {
                  ref.read(schedulesProvider.notifier).updateIntervalDays(schedule.id, schedule.intervalDays - 1);
                }
              },
              icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF156082)),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Center(
                  child: Text(
                    '${schedule.intervalDays}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF156082)),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                ref.read(schedulesProvider.notifier).updateIntervalDays(schedule.id, schedule.intervalDays + 1);
              },
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF156082)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgramModeToggle(ScheduleEntity schedule, AppLocalizations localizations) {
    return Row(
      children: [
        const Icon(Icons.settings_remote, size: 18, color: Color(0xFF666666)),
        const SizedBox(width: 8),
        Text(localizations.programMode,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
        const Spacer(),
        Text(localizations.autoMode,
            style: TextStyle(
              fontSize: 12,
              color: schedule.programAutoMode ? const Color(0xFF4CAF50) : Colors.grey,
            )),
        const SizedBox(width: 4),
        Switch(
          value: schedule.programAutoMode,
          activeColor: const Color(0xFF4CAF50),
          onChanged: (_) {
            ref.read(schedulesProvider.notifier).toggleProgramMode(schedule.id);
          },
        ),
        const SizedBox(width: 4),
        Text(localizations.manualMode,
            style: TextStyle(
              fontSize: 12,
              color: !schedule.programAutoMode ? const Color(0xFFFF9800) : Colors.grey,
            )),
      ],
    );
  }

  Widget _buildNoWaterWindow(ScheduleEntity schedule, AppLocalizations localizations) {
    final window = schedule.noWaterWindow;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.block, size: 18, color: Color(0xFFE53935)),
            const SizedBox(width: 8),
            Text(localizations.noWaterWindowLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
            const Spacer(),
            Switch(
              value: window.enabled,
              activeColor: const Color(0xFFE53935),
              onChanged: (v) {
                ref.read(schedulesProvider.notifier).updateNoWaterWindow(
                      schedule.id,
                      window.copyWith(enabled: v),
                    );
              },
            ),
          ],
        ),
        Text(localizations.noWaterWindowDesc,
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        if (window.enabled) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTimePickerButton(
                  label: localizations.startTimeLabel,
                  time: window.startTime,
                  onTap: () async {
                    final picked = await _showTimePickerDialog(
                      initial: window.startTime,
                      localizations: localizations,
                    );
                    if (picked != null) {
                      ref.read(schedulesProvider.notifier).updateNoWaterWindow(
                            schedule.id,
                            window.copyWith(startTime: picked),
                          );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimePickerButton(
                  label: localizations.endTimeLabel,
                  time: window.endTime,
                  onTap: () async {
                    final picked = await _showTimePickerDialog(
                      initial: window.endTime,
                      localizations: localizations,
                    );
                    if (picked != null) {
                      ref.read(schedulesProvider.notifier).updateNoWaterWindow(
                            schedule.id,
                            window.copyWith(endTime: picked),
                          );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTimePickerButton({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Color(0xFF156082)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  Text(time,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationDelaySection(ScheduleEntity schedule, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF666666)),
            const SizedBox(width: 8),
            Text(localizations.stationDelay,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
          ],
        ),
        Text(localizations.stationDelayDesc, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 8),
        _buildHmsInput(
          value: schedule.stationDelay,
          onChanged: (v) {
            ref.read(schedulesProvider.notifier).updateStationDelay(schedule.id, v);
          },
        ),
      ],
    );
  }

  Widget _buildHmsInput({required String value, required ValueChanged<String> onChanged}) {
    final parts = value.split(':');
    final hh = parts.isNotEmpty ? parts[0] : '00';
    final mm = parts.length > 1 ? parts[1] : '00';
    final ss = parts.length > 2 ? parts[2] : '30';

    return Row(
      children: [
        _buildNumberField(
          label: 'HH',
          value: hh,
          onChanged: (v) {
            final newHH = v.padLeft(2, '0');
            onChanged('$newHH:$mm:$ss');
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(':', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        _buildNumberField(
          label: 'MM',
          value: mm,
          onChanged: (v) {
            final newMM = v.padLeft(2, '0');
            onChanged('$hh:$newMM:$ss');
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(':', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        _buildNumberField(
          label: 'SS',
          value: ss,
          onChanged: (v) {
            final newSS = v.padLeft(2, '0');
            onChanged('$hh:$mm:$newSS');
          },
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: TextEditingController(text: value),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              maxLength: 2,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackOverlapSelector(ScheduleEntity schedule, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.view_agenda, size: 18, color: Color(0xFF666666)),
            const SizedBox(width: 8),
            Text(localizations.stackOrOverlap,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(schedulesProvider.notifier).updateStackOverlapMode(
                        schedule.id,
                        StackOverlapMode.stack,
                      );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: schedule.stackOverlapMode == StackOverlapMode.stack
                        ? const Color(0xFF156082).withOpacity(0.1)
                        : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: schedule.stackOverlapMode == StackOverlapMode.stack
                          ? const Color(0xFF156082)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.view_agenda,
                          color: schedule.stackOverlapMode == StackOverlapMode.stack
                              ? const Color(0xFF156082)
                              : Colors.grey),
                      const SizedBox(height: 4),
                      Text(localizations.stackMode,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: schedule.stackOverlapMode == StackOverlapMode.stack
                                ? const Color(0xFF156082)
                                : Colors.grey[600],
                          )),
                      Text(localizations.stackDesc,
                          style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(schedulesProvider.notifier).updateStackOverlapMode(
                        schedule.id,
                        StackOverlapMode.overlap,
                      );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: schedule.stackOverlapMode == StackOverlapMode.overlap
                        ? const Color(0xFF156082).withOpacity(0.1)
                        : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: schedule.stackOverlapMode == StackOverlapMode.overlap
                          ? const Color(0xFF156082)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.layers,
                          color: schedule.stackOverlapMode == StackOverlapMode.overlap
                              ? const Color(0xFF156082)
                              : Colors.grey),
                      const SizedBox(height: 4),
                      Text(localizations.overlapMode,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: schedule.stackOverlapMode == StackOverlapMode.overlap
                                ? const Color(0xFF156082)
                                : Colors.grey[600],
                          )),
                      Text(localizations.overlapDesc,
                          style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartTimesSection(ScheduleEntity schedule, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, size: 18, color: Color(0xFF666666)),
            const SizedBox(width: 8),
            Text(localizations.startTimes,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
          ],
        ),
        const SizedBox(height: 8),
        ...schedule.startTimes.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: entry.enabled ? const Color(0xFFF5F7FA) : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: entry.enabled ? const Color(0xFF156082).withOpacity(0.3) : const Color(0xFFE0E0E0),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    '${localizations.startTimeNumber} ${entry.index}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: entry.enabled ? const Color(0xFF333333) : Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: entry.enabled
                        ? () async {
                            final picked = await _showTimePickerDialog(
                              initial: entry.time,
                              localizations: localizations,
                            );
                            if (picked != null) {
                              ref.read(schedulesProvider.notifier).updateStartTime(schedule.id, entry.index, picked);
                            }
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time,
                              size: 14,
                              color: entry.enabled ? const Color(0xFF156082) : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            entry.time,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: entry.enabled ? const Color(0xFF333333) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: entry.enabled,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (_) {
                    ref.read(schedulesProvider.notifier).toggleStartTime(schedule.id, entry.index);
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRunTimesSection(ScheduleEntity schedule, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timer, size: 18, color: Color(0xFF666666)),
            const SizedBox(width: 8),
            Text(localizations.runTimes,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildRunTimeHeader(localizations.minimum, localizations),
            _buildRunTimeHeader(localizations.recommended100, localizations),
            _buildRunTimeHeader(localizations.maximum, localizations),
          ],
        ),
        const SizedBox(height: 8),
        ...schedule.blocks.map<Widget>((block) {
          final adjusted = block.seasonalAdjustedMinutes;
          final minRun = adjusted * 0.5;
          final maxRun = adjusted * 1.5;
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(block.name,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: Text('${minRun.toStringAsFixed(0)} min',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF156082).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('${adjusted.toStringAsFixed(0)} min',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF156082)),
                        textAlign: TextAlign.center),
                  ),
                ),
                Expanded(
                  child: Text('${maxRun.toStringAsFixed(0)} min',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRunTimeHeader(String label, AppLocalizations localizations) {
    return Expanded(
      child: Text(label,
          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          textAlign: TextAlign.center),
    );
  }

  Widget _buildBlockTile(ProgramBlock block, ScheduleEntity schedule, AppLocalizations localizations) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(block.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  '${localizations.seasonalAdjustment}: ${block.seasonalAdjustedMinutes.toStringAsFixed(0)} min',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Text(block.runTime,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
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
          Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(localizations.noPrograms,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(localizations.tapToAddProgram,
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Future<String?> _showTimePickerDialog({
    required String initial,
    required AppLocalizations localizations,
  }) async {
    final parts = initial.replaceAll(RegExp(r' [AP]M'), '').split(':');
    int hour = int.tryParse(parts[0]) ?? 6;
    int minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final isPM = initial.contains('PM');
    if (isPM && hour < 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    if (picked != null) {
      final period = picked.hour >= 12 ? 'PM' : 'AM';
      final displayHour = picked.hour > 12 ? picked.hour - 12 : (picked.hour == 0 ? 12 : picked.hour);
      return '${displayHour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';
    }
    return null;
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF156082)),
            child: Text(localizations.add),
          ),
        ],
      ),
    );
  }
}
