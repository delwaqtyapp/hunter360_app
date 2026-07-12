import 'package:flutter/material.dart';

class ManualOperationPanel extends StatelessWidget {
  const ManualOperationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manual Operation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _actionButton(context, 'Start All', Icons.play_arrow, Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _actionButton(context, 'Stop All', Icons.stop, Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _actionButton(context, 'Pull In', Icons.arrow_upward, Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _actionButton(context, 'Pull Out', Icons.arrow_downward, Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label command sent')),
        );
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
