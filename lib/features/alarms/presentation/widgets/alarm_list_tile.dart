import 'package:flutter/material.dart';
import '../../domain/entities/alarm.dart';

class AlarmListTile extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback? onAcknowledge;

  const AlarmListTile({super.key, required this.alarm, this.onAcknowledge});

  Color get _severityColor {
    switch (alarm.severity) {
      case 'critical': return Colors.red;
      case 'error': return Colors.orange;
      case 'warning': return Colors.amber;
      default: return Colors.blue;
    }
  }

  IconData get _typeIcon {
    switch (alarm.type) {
      case 'flow': return Icons.water_drop;
      case 'communication': return Icons.wifi_off;
      case 'weather': return Icons.cloud;
      default: return Icons.warning_amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _severityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_typeIcon, color: _severityColor, size: 20),
        ),
        title: Text(alarm.message, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: Text(
          '${alarm.controllerName} - ${alarm.severity.toUpperCase()}',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        trailing: alarm.acknowledged
            ? Icon(Icons.check_circle, color: Colors.green.shade400, size: 20)
            : IconButton(
                icon: Icon(Icons.notifications_active, color: _severityColor, size: 20),
                onPressed: onAcknowledge,
              ),
      ),
    );
  }
}
