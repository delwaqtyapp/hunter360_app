import 'package:equatable/equatable.dart';

class WeatherStation extends Equatable {
  final String id;
  final String name;
  final String type;
  final String status;
  final double temperature;
  final double humidity;
  final double rainfall;
  final double windSpeed;
  final double soilMoisture;
  final DateTime lastReading;

  const WeatherStation({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.temperature = 0,
    this.humidity = 0,
    this.rainfall = 0,
    this.windSpeed = 0,
    this.soilMoisture = 0,
    required this.lastReading,
  });

  factory WeatherStation.fromJson(Map<String, dynamic> json) {
    return WeatherStation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'WS-360-CELL',
      status: json['status'] ?? 'offline',
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      rainfall: (json['rainfall'] ?? 0).toDouble(),
      windSpeed: (json['windSpeed'] ?? 0).toDouble(),
      soilMoisture: (json['soilMoisture'] ?? 0).toDouble(),
      lastReading: DateTime.parse(json['lastReading'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  List<Object?> get props => [id, name, temperature, humidity];
}
