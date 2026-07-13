import 'package:equatable/equatable.dart';

enum MarkerType { site, controller, station, flowSensor, pmv }

class MapMarker extends Equatable {
  final String id;
  final String controllerId;
  final String name;
  final double latitude;
  final double longitude;
  final String status;
  final int activeValves;
  final MarkerType type;
  final String description;
  final String parentController;

  const MapMarker({
    required this.id,
    required this.controllerId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.activeValves = 0,
    this.type = MarkerType.site,
    this.description = '',
    this.parentController = '',
  });

  bool get isOnline => status == 'online';

  @override
  List<Object?> get props => [
        id,
        controllerId,
        name,
        latitude,
        longitude,
        status,
        type,
        activeValves,
      ];
}
