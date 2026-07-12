import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _reportCard(context, 'Water Usage Report', 'Daily, Weekly, Monthly water consumption analysis', Icons.water_drop, Colors.blue),
          _reportCard(context, 'Controller Report', 'Controller status and performance metrics', Icons.precision_manufacturing, Colors.green),
          _reportCard(context, 'Schedule Report', 'Schedule execution and compliance', Icons.schedule, Colors.orange),
          _reportCard(context, 'Alarm Report', 'Alarm history and resolution times', Icons.warning_amber, Colors.red),
          _reportCard(context, 'Energy Report', 'Energy consumption and efficiency', Icons.bolt, Colors.purple),
          _reportCard(context, 'Weather Report', 'Weather data and ET analysis', Icons.cloud, Colors.teal),
        ],
      ),
    );
  }

  Widget _reportCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
