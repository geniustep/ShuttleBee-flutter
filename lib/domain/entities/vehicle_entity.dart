import 'package:equatable/equatable.dart';

/// كيان المركبة (Vehicle Entity)
class VehicleEntity extends Equatable {
  const VehicleEntity({
    required this.id,
    required this.name,
    required this.seatCapacity,
    this.licensePlate,
    this.driverId,
    this.driverName,
  });

  final int id;
  final String name;
  final int seatCapacity;
  final String? licensePlate;
  final int? driverId;
  final String? driverName;

  /// هل المركبة لديها سائق
  bool get hasDriver => driverId != null;

  @override
  List<Object?> get props => [
        id,
        name,
        seatCapacity,
        licensePlate,
        driverId,
        driverName,
      ];
}
