import 'package:equatable/equatable.dart';

class SensorReading extends Equatable {
  final String id;
  final String sensorType;
  final double value;
  final String unit;
  final DateTime timestamp;

  const SensorReading({
    required this.id,
    required this.sensorType,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, sensorType, value, unit, timestamp];
}
