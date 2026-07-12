import 'package:flutter/material.dart';

class ScheduleEditorPage extends StatefulWidget {
  const ScheduleEditorPage({super.key});

  @override
  State<ScheduleEditorPage> createState() => _ScheduleEditorPageState();
}

class _ScheduleEditorPageState extends State<ScheduleEditorPage> {
  final _nameController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 6, minute: 0);
  int _seasonalAdjustment = 100;
  List<bool> _selectedDays = [true, true, true, true, true, true, true];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Schedule'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule saved')));
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Schedule Name', hintText: 'Enter schedule name'),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text('${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _startTime);
                if (time != null) setState(() => _startTime = time);
              },
            ),
            const SizedBox(height: 16),
            const Text('Days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].asMap().entries.map((e) {
                return FilterChip(
                  label: Text(e.value),
                  selected: _selectedDays[e.key],
                  onSelected: (v) => setState(() => _selectedDays[e.key] = v),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Seasonal Adjustment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Slider(
              value: _seasonalAdjustment.toDouble(),
              min: 0,
              max: 150,
              divisions: 30,
              label: '$_seasonalAdjustment%',
              onChanged: (v) => setState(() => _seasonalAdjustment = v.round()),
            ),
            Text('Adjustment: $_seasonalAdjustment%', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
