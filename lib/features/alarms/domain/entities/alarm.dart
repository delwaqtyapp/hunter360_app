import 'package:equatable/equatable.dart';

class Alarm extends Equatable {
  final String id;
  final String controllerId;
  final String controllerName;
  final String type;
  final String severity;
  final String message;
  final String timestamp;
  final bool acknowledged;
  final int priority;

  const Alarm({
    required this.id,
    this.controllerId = '',
    this.controllerName = '',
    this.type = '',
    this.severity = 'info',
    required this.message,
    required this.timestamp,
    this.acknowledged = false,
    this.priority = 1,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      controllerId: json['ControllerId']?.toString() ?? '',
      controllerName: json['ControllerName']?.toString() ?? '',
      type: json['Type']?.toString() ?? '',
      severity: json['Severity']?.toString() ?? json['Priority']?.toString() ?? 'info',
      message: json['Message']?.toString() ?? json['Tag']?.toString() ?? '',
      timestamp: json['Timestamp']?.toString() ?? json['DateTime']?.toString() ?? '',
      acknowledged: json['Acknowledged'] == true || json['Acked'] == true,
      priority: json['Priority'] is int ? json['Priority'] : int.tryParse(json['Priority']?.toString() ?? '1') ?? 1,
    );
  }

  @override
  List<Object?> get props => [id, type, severity, message, timestamp, acknowledged, priority];
}
