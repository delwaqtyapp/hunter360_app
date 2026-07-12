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
  final String alarmType;
  final String tagValue;
  final String state;
  final String userDef3;

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
    this.alarmType = '',
    this.tagValue = '',
    this.state = '',
    this.userDef3 = '',
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    final priority = json['Priority'] is int ? json['Priority'] : int.tryParse(json['Priority']?.toString() ?? '1') ?? 1;
    final acked = json['Ack']?.toString().toLowerCase() == 'acked';
    final tagGroup = json['TagGroup']?.toString() ?? '';
    final alarmComment = json['AlarmComment']?.toString() ?? json['Message']?.toString() ?? '';

    String severity;
    if (priority >= 4) {
      severity = 'critical';
    } else if (priority >= 2) {
      severity = 'warning';
    } else {
      severity = 'info';
    }

    return Alarm(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      controllerId: tagGroup,
      controllerName: json['User_Def_3']?.toString() ?? tagGroup,
      type: json['AlarmType']?.toString() ?? json['Type']?.toString() ?? '',
      severity: severity,
      message: alarmComment,
      timestamp: json['AlarmTime']?.toString() ?? json['Timestamp']?.toString() ?? '',
      acknowledged: acked,
      priority: priority,
      alarmType: json['AlarmType']?.toString() ?? '',
      tagValue: json['TagValue']?.toString() ?? '',
      state: json['State']?.toString() ?? '',
      userDef3: json['User_Def_3']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, type, severity, message, timestamp, acknowledged, priority];
}
