import 'package:equatable/equatable.dart';

class Valve extends Equatable {
  final String id;
  final int stationNumber;
  final String name;
  final String status;
  final double flowRate;
  final int runtime;

  const Valve({
    required this.id,
    required this.stationNumber,
    required this.name,
    required this.status,
    this.flowRate = 0,
    this.runtime = 0,
  });

  Valve copyWith({String? status, double? flowRate, int? runtime}) {
    return Valve(
      id: id,
      stationNumber: stationNumber,
      name: name,
      status: status ?? this.status,
      flowRate: flowRate ?? this.flowRate,
      runtime: runtime ?? this.runtime,
    );
  }

  bool get isOpen => status == 'open';

  @override
  List<Object?> get props => [id, stationNumber, name, status, flowRate];
}
