import 'package:equatable/equatable.dart';

class MapMarker extends Equatable {
  final String id;
  final String controllerId;
  final String name;
  final double latitude;
  final double longitude;
  final String status;
  final int activeValves;

  const MapMarker({
    required this.id,
    required this.controllerId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.activeValves = 0,
  });

  bool get isOnline => status == 'online';

  @override
  List<Object?> get props => [id, controllerId, name, latitude, longitude, status];
}
