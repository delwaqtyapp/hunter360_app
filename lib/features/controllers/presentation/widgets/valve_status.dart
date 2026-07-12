import 'package:flutter/material.dart';
import '../../domain/entities/valve.dart';

class ValveStatusCard extends StatelessWidget {
  final Valve valve;
  final VoidCallback? onToggle;

  const ValveStatusCard({super.key, required this.valve, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: valve.isOpen ? Colors.blue.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.water_drop,
                color: valve.isOpen ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(valve.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    'Station ${valve.stationNumber} - ${valve.isOpen ? "${valve.flowRate.toStringAsFixed(1)} L/min" : "Closed"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Switch(
              value: valve.isOpen,
              onChanged: (_) => onToggle?.call(),
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
