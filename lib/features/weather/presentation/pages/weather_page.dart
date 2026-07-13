import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/core/services/realtime_service.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  String _selectedStation = 'WS-360';
  double _temperature = 28.5;
  double _humidity = 65.0;
  double _windSpeed = 12.3;
  double _rainfall = 2.5;
  double _soilMoisture = 45.0;
  double _et = 5.2;
  List<FlSpot> _temperatureHistory = [];
  List<FlSpot> _humidityHistory = [];

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  void _generateMockData() {
    _temperatureHistory = List.generate(24, (index) {
      return FlSpot(
        index.toDouble(),
        20 + (index * 0.5) + (index > 12 ? -((index - 12) * 0.3) : 0),
      );
    });
    _humidityHistory = List.generate(24, (index) {
      return FlSpot(
        index.toDouble(),
        70 - (index * 1.5) + (index > 14 ? ((index - 14) * 2) : 0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF156082),
        title: Text(
          localizations.weatherStation,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStationSelector(localizations),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCurrentConditionsHeader(localizations),
                const SizedBox(height: 16),
                _buildWeatherCards(localizations),
                const SizedBox(height: 16),
                _buildSoilMoistureSection(localizations),
                const SizedBox(height: 16),
                _buildETPanel(localizations),
                const SizedBox(height: 16),
                _buildWeatherChart(localizations),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationSelector(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.cloud, color: Color(0xFF156082), size: 20),
          const SizedBox(width: 8),
          Text(
            localizations.station,
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
                  value: _selectedStation,
                  items: const [
                    DropdownMenuItem(
                      value: 'WS-360',
                      child: Text('WS-360'),
                    ),
                    DropdownMenuItem(
                      value: 'WS-361',
                      child: Text('WS-361'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStation = value;
                      });
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

  Widget _buildCurrentConditionsHeader(AppLocalizations localizations) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF156082)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.wb_sunny, color: Colors.white, size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.currentConditions,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water_drop, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_humidity.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.air, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_windSpeed.toStringAsFixed(1)} km/h',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCards(AppLocalizations localizations) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildGaugeCard(
          localizations.temperature,
          '${_temperature.toStringAsFixed(1)}°C',
          const Color(0xFFFF5722),
          Icons.thermostat,
          _temperature / 50,
        ),
        _buildGaugeCard(
          localizations.humidity,
          '${_humidity.toStringAsFixed(0)}%',
          const Color(0xFF2196F3),
          Icons.water_drop,
          _humidity / 100,
        ),
        _buildGaugeCard(
          localizations.windSpeed,
          '${_windSpeed.toStringAsFixed(1)} km/h',
          const Color(0xFF4CAF50),
          Icons.air,
          _windSpeed / 50,
        ),
        _buildGaugeCard(
          localizations.rainfall,
          '${_rainfall.toStringAsFixed(1)} mm',
          const Color(0xFF9C27B0),
          Icons.grain,
          _rainfall / 20,
        ),
      ],
    );
  }

  Widget _buildGaugeCard(String title, String value, Color color, IconData icon, double percent) {
    final clampedPercent = percent.clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: clampedPercent,
                      strokeWidth: 8,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            value.split(' ')[0],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                          if (value.split(' ').length > 1)
                            Text(
                              value.split(' ')[1],
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilMoistureSection(AppLocalizations localizations) {
    final soilZones = [
      {'zone': localizations.zone1, 'moisture': 42.0},
      {'zone': localizations.zone2, 'moisture': 55.0},
      {'zone': localizations.zone3, 'moisture': 38.0},
      {'zone': localizations.zone4, 'moisture': 61.0},
    ];

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
                const Icon(Icons.eco, color: Color(0xFF4CAF50), size: 22),
                const SizedBox(width: 8),
                Text(
                  localizations.soilMoisture,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_soilMoisture.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...soilZones.map((zone) {
              final moisture = zone['moisture'] as double;
              final isLow = moisture < 40;
              final isHigh = moisture > 60;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        zone['zone'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: moisture / 100,
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isLow
                                ? const Color(0xFFFF9800)
                                : isHigh
                                    ? const Color(0xFF2196F3)
                                    : const Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${moisture.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLow
                              ? const Color(0xFFFF9800)
                              : isHigh
                                  ? const Color(0xFF2196F3)
                                  : const Color(0xFF4CAF50),
                        ),
                        textAlign: TextAlign.right,
                      ),
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

  Widget _buildETPanel(AppLocalizations localizations) {
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
                const Icon(Icons.water, color: Color(0xFF03A9F4), size: 22),
                const SizedBox(width: 8),
                Text(
                  localizations.evapotranspiration,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildETStat(
                    localizations.dailyET,
                    '${_et.toStringAsFixed(1)} mm',
                    Icons.today,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFFBBDEFB),
                  ),
                  _buildETStat(
                    localizations.weeklyET,
                    '${(_et * 5.8).toStringAsFixed(1)} mm',
                    Icons.date_range,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFFBBDEFB),
                  ),
                  _buildETStat(
                    localizations.monthlyET,
                    '${(_et * 25).toStringAsFixed(0)} mm',
                    Icons.calendar_month,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF156082), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      localizations.etBasedOnPenmanMonteith,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildETStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF156082), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF156082),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherChart(AppLocalizations localizations) {
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
                const Icon(Icons.show_chart, color: Color(0xFF156082), size: 22),
                const SizedBox(width: 8),
                Text(
                  localizations.weatherHistory,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF156082).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '24H',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF156082),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildLegendItem(const Color(0xFFFF5722), localizations.temperature),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFF2196F3), localizations.humidity),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: const Color(0xFFF0F0F0),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          final hours = ['00', '04', '08', '12', '16', '20', '24'];
                          final index = (value / 4).toInt();
                          if (index >= 0 && index < hours.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                hours[index],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 24,
                  minY: 0,
                  maxY: 80,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _temperatureHistory,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
                      ),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF5722).withOpacity(0.2),
                            const Color(0xFFFF5722).withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    LineChartBarData(
                      spots: _humidityHistory,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF03A9F4)],
                      ),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2196F3).withOpacity(0.2),
                            const Color(0xFF2196F3).withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}