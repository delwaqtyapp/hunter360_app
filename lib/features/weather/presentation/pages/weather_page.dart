import 'package:flutter/material.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(Icons.wb_sunny, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text('32.5°C', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  Text('Main Weather Station', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: [
                _weatherCard(Icons.water_drop, 'Humidity', '65%', Colors.blue),
                _weatherCard(Icons.air, 'Wind', '12.3 km/h', Colors.teal),
                _weatherCard(Icons.grain, 'Rain', '0.0 mm', Colors.indigo),
                _weatherCard(Icons.thermostat, 'Soil Moisture', '45%', Colors.brown),
                _weatherCard(Icons.eco, 'ET Rate', '5.2 mm/day', Colors.green),
                _weatherCard(Icons.sunny, 'Solar Radiation', '850 W/m²', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
