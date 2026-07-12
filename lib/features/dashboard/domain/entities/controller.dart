import 'package:equatable/equatable.dart';

class ControllerEntity extends Equatable {
  final String id;
  final String name;
  final String model;
  final String status;
  final String ipAddress;
  final double? latitude;
  final double? longitude;
  final int valveCount;
  final int activeValves;
  final DateTime lastSeen;

  const ControllerEntity({
    required this.id,
    required this.name,
    required this.model,
    required this.status,
    required this.ipAddress,
    this.latitude,
    this.longitude,
    this.valveCount = 0,
    this.activeValves = 0,
    required this.lastSeen,
  });

  factory ControllerEntity.fromJson(Map<String, dynamic> json) {
    return ControllerEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      model: json['model'] ?? 'ACC2',
      status: json['status'] ?? 'offline',
      ipAddress: json['ipAddress'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      valveCount: json['valveCount'] ?? 0,
      activeValves: json['activeValves'] ?? 0,
      lastSeen: DateTime.parse(json['lastSeen'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isOnline => status == 'online';

  @override
  List<Object?> get props => [id, name, model, status, ipAddress, valveCount, activeValves];
}
