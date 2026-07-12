import 'package:equatable/equatable.dart';

class Alarm extends Equatable {
  final String id;
  final String controllerId;
  final String controllerName;
  final String type;
  final String severity;
  final String message;
  final DateTime timestamp;
  final bool acknowledged;

  const Alarm({
    required this.id,
    required this.controllerId,
    required this.controllerName,
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    this.acknowledged = false,
  });

  @override
  List<Object?> get props => [id, type, severity, message, timestamp, acknowledged];
}
