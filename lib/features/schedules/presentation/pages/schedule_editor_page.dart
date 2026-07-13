import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/features/controllers/presentation/providers/controllers_provider.dart';
import '../providers/schedule_editor_provider.dart';

class ScheduleEditorPage extends ConsumerStatefulWidget {
  final String? controllerId;
  final int? programIndex;

  const ScheduleEditorPage({super.key, this.controllerId, this.programIndex});

  @override
  ConsumerState<ScheduleEditorPage> createState() => _ScheduleEditorPageState();
}

class _ScheduleEditorPageState extends ConsumerState<ScheduleEditorPage> {
  String _selectedController = 'C001';

  @override
  void initState() {
    super.initState();
    _selectedController = widget.controllerId ?? 'C001';
    Future.microtask(() {
      ref.read(scheduleEditorProvider.notifier).setController(_selectedController);
      if (widget.programIndex != null) {
        ref.read(scheduleEditorProvider.notifier).setProgram(widget.programIndex!);
      }
      _loadStations();
    });
  }

  void _loadStations() {
    ref.read(controllersProvider.notifier).loadStationsForController(_selectedController);
    final ctrlState = ref.read(controllersProvider);
    final stations = ctrlState.valves.map((v) => StationRunTime(
      stationId: v.id,
      stationName: v.name,
      stationNumber: v.stationNumber,
    )).toList();
    ref.read(scheduleEditorProvider.notifier).loadStations(stations);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editorState = ref.watch(scheduleEditorProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF156082),
        title: Text(l10n.scheduleEditorTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: editorState.isSaving ? null : () => _saveSchedule(l10n),
            child: editorState.isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(l10n.save, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildControllerSelector(l10n, colorScheme),
            const SizedBox(height: 16),
            _buildProgramSelection(l10n, editorState, colorScheme),
            const SizedBox(height: 16),
            _buildScheduleTypeSelector(l10n, editorState, colorScheme),
            const SizedBox(height: 16),
            _buildDaySelection(l10n, editorState, colorScheme),
            const SizedBox(height: 16),
            _buildStartTimesSection(l10n, editorState, colorScheme),
            const SizedBox(height: 16),
            _buildNoWaterWindow(l10n, editorState, colorScheme),
            const SizedBox(height: 16),
            _buildStationList(l10n, editorState, colorScheme),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: editorState.isSaving ? null : () => _saveSchedule(l10n),
                icon: editorState.isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(l10n.saveSchedule, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF156082),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildControllerSelector(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.device_hub, color: colorScheme.primary, size: 22),
            const SizedBox(width: 10),
            Text(l10n.controller, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                    value: _selectedController,
                    items: AppConstants.controllers.map((c) {
                      return DropdownMenuItem(value: c['id']!, child: Text('${c['id']} - ${c['name']}'));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedController = value);
                        ref.read(scheduleEditorProvider.notifier).setController(value);
                        _loadStations();
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramSelection(AppLocalizations l10n, ScheduleEditorState editorState, ColorScheme colorScheme) {
    final programs = [l10n.programA, l10n.programB, l10n.programC, l10n.programD];

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
                const Icon(Icons.event_note, color: Color(0xFF156082)),
                const SizedBox(width: 8),
                Text(l10n.programLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(4, (i) {
                final isSelected = editorState.selectedProgram == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(scheduleEditorProvider.notifier).setProgram(i),
                    child: Container(
                      margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? colorScheme.primary : const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            String.fromCharCode(65 + i),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            programs[i],
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? Colors.white70 : Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTypeSelector(AppLocalizations l10n, ScheduleEditorState editorState, ColorScheme colorScheme) {
    final types = [
      (ScheduleType.weekly, l10n.weeklyLabel, Icons.calendar_view_week),
      (ScheduleType.oddEven, l10n.oddEvenLabel, Icons.date_range),
      (ScheduleType.interval, l10n.intervalLabel, Icons.timelapse),
    ];

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
                const Icon(Icons.schedule, color: Color(0xFF156082)),
                const SizedBox(width: 8),
                Text(l10n.scheduleTypeLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: types.map((type) {
                final isSelected = editorState.scheduleType == type.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(scheduleEditorProvider.notifier).setScheduleType(type.$1),
                    child: Container(
                      margin: EdgeInsets.only(right: type != types.last ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary.withOpacity(0.1) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? colorScheme.primary : const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        children: [
                          Icon(type.$3, color: isSelected ? colorScheme.primary : Colors.grey, size: 24),
                          const SizedBox(height: 6),
                          Text(
                            type.$2,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? colorScheme.primary : Colors.grey.shade600,
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
        ),
      ),
    );
  }

  Widget _buildDaySelection(AppLocalizations l10n, ScheduleEditorState editorState, ColorScheme colorScheme) {
    final dayLabels = [
      l10n.sunday, l10n.monday, l10n.tuesday, l10n.wednesday,
      l10n.thursday, l10n.friday, l10n.saturday,
    ];

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
                const Icon(Icons.calendar_today, color: Color(0xFF156082)),
                const SizedBox(width: 8),
                Text(l10n.daySelection, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (i) {
                final isSelected = editorState.selectedDays[i];
                return GestureDetector(
                  onTap: () => ref.read(scheduleEditorProvider.notifier).toggleDay(i),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? colorScheme.primary : const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? Colors.white : Colors.grey.shade400,
                          size: 16,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dayLabels[i],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartTimesSection(AppLocalizations l10n, ScheduleEditorState editorState, ColorScheme colorScheme) {
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
                const Icon(Icons.access_time, color: Color(0xFF156082)),
                const SizedBox(width: 8),
                Text(l10n.startTimesLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (editorState.startTimes.length < 10)
                  TextButton.icon(
                    onPressed: () => _pickStartTime(l10n),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: Text(l10n.add, style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            if (editorState.startTimes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(l10n.noData, style: TextStyle(color: Colors.grey.shade400)),
                ),
              )
            else
              ...List.generate(editorState.startTimes.length, (i) {
                final time = editorState.startTimes[i];
                final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 18, color: Color(0xFF156082)),
                      const SizedBox(width: 10),
                      Text(timeStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('#${i + 1}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => ref.read(scheduleEditorProvider.notifier).removeStartTime(i),
                        child: Icon(Icons.remove_circle_outline, color: Colors.red.shade400, size: 20),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWaterWindow(AppLocalizations l10n, ScheduleEditorState editorState, ColorScheme colorScheme) {
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
                const Icon(Icons.water_drop_outlined, color: Color(0xFF156082)),
                const SizedBox(width: 8),
                Text(l10n.noWaterWindow, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimePickerButton(
                    l10n.noWaterStart,
                    editorState.noWaterStart,
                    () => _pickNoWaterStart(l10n),
                    colorScheme,
                    l10n,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePickerButton(
                    l10n.noWaterEnd,
                    editorState.noWaterEnd,
                    () => _pickNoWaterEnd(l10n),
                    colorScheme,
                    l10n,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerButton(String label, TimeOfDay? time, VoidCallback onTap, ColorScheme colorScheme, AppLocalizations l10n) {
    final timeStr = time != null ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}' : '--:--';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: time != null ? colorScheme.primary : const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(timeStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationList(AppLocalizations l10n, ScheduleEditorState editorState, ColorScheme colorScheme) {
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
                const Icon(Icons.format_list_numbered, color: Color(0xFF156082)),
                const SizedBox(width: 8),
                Text(l10n.stationListLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${editorState.stations.where((s) => s.enabled).length}/${editorState.stations.length}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.wb_sunny, size: 16, color: Colors.orange.shade600),
                const SizedBox(width: 4),
                Text(
                  '${l10n.seasonalIndicator}: ${editorState.seasonalAdjustment}%',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (editorState.stations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(l10n.noStationsFound, style: TextStyle(color: Colors.grey.shade400)),
                ),
              )
            else
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: editorState.stations.length,
                  itemBuilder: (context, index) {
                    final station = editorState.stations[index];
                    return _buildStationItem(l10n, station, index, colorScheme);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationItem(AppLocalizations l10n, StationRunTime station, int index, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: station.enabled ? colorScheme.primary.withOpacity(0.05) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: station.enabled ? colorScheme.primary.withOpacity(0.3) : const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: station.enabled ? colorScheme.primary : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${station.stationNumber}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: station.enabled ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.stationName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: station.enabled ? const Color(0xFF333333) : Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.wb_sunny, size: 10, color: Colors.orange.shade400),
                    const SizedBox(width: 2),
                    Text(l10n.seasonalIndicator, style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            child: TextFormField(
              initialValue: station.runTimeMinutes > 0 ? '${station.runTimeMinutes}' : '',
              keyboardType: TextInputType.number,
              enabled: station.enabled,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey.shade300),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                suffixText: l10n.minutesUnit,
                suffixStyle: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                isDense: true,
              ),
              onChanged: (value) {
                final minutes = int.tryParse(value) ?? 0;
                ref.read(scheduleEditorProvider.notifier).updateStationRunTime(index, minutes);
              },
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: station.enabled,
            activeColor: colorScheme.primary,
            onChanged: (_) => ref.read(scheduleEditorProvider.notifier).toggleStation(index),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStartTime(AppLocalizations l10n) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 6, minute: 0),
    );
    if (time != null) {
      ref.read(scheduleEditorProvider.notifier).addStartTime(time);
    }
  }

  Future<void> _pickNoWaterStart(AppLocalizations l10n) async {
    final time = await showTimePicker(
      context: context,
      initialTime: ref.read(scheduleEditorProvider).noWaterStart ?? const TimeOfDay(hour: 22, minute: 0),
    );
    if (time != null) {
      ref.read(scheduleEditorProvider.notifier).setNoWaterStart(time);
    }
  }

  Future<void> _pickNoWaterEnd(AppLocalizations l10n) async {
    final time = await showTimePicker(
      context: context,
      initialTime: ref.read(scheduleEditorProvider).noWaterEnd ?? const TimeOfDay(hour: 6, minute: 0),
    );
    if (time != null) {
      ref.read(scheduleEditorProvider.notifier).setNoWaterEnd(time);
    }
  }

  void _saveSchedule(AppLocalizations l10n) async {
    await ref.read(scheduleEditorProvider.notifier).saveSchedule();
    final state = ref.read(scheduleEditorProvider);
    if (!mounted) return;
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: ${state.error}'), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scheduleSaved), backgroundColor: const Color(0xFF4CAF50)),
      );
      Navigator.pop(context);
    }
  }
}
