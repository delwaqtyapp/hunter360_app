import 'package:flutter/material.dart';

class FlowPage extends StatelessWidget {
  const FlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0097A7), Color(0xFF00BCD4)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Flow Today', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text('12,500 L', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('480 L/min current', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Flow Meters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _flowMeterCard('Main Meter', 480, 500, true),
            _flowMeterCard('Zone 1 Meter', 120, 150, true),
            _flowMeterCard('Zone 2 Meter', 85, 150, true),
            _flowMeterCard('Zone 3 Meter', 0, 150, false),
          ],
        ),
      ),
    );
  }

  Widget _flowMeterCard(String name, double current, double max, bool active) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: active ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(active ? 'Active' : 'Inactive', style: TextStyle(fontSize: 11, color: active ? Colors.green : Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: max > 0 ? current / max : 0,
              backgroundColor: Colors.grey.shade200,
              color: current / max > 0.9 ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 8),
            Text('${current.toStringAsFixed(0)} / ${max.toStringAsFixed(0)} L/min', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
