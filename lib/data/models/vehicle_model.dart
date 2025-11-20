import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/domain/entities/vehicle_entity.dart';

part 'vehicle_model.freezed.dart';
part 'vehicle_model.g.dart';

/// نموذج المركبة (Vehicle Model)
@freezed
class VehicleModel with _$VehicleModel {
  const VehicleModel._();

  const factory VehicleModel({
    required int id,
    required String name,
    required int seatCapacity,
    String? licensePlate,
    int? driverId,
    String? driverName,
  }) = _VehicleModel;

  /// من JSON
  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  /// من BridgeCore API Response
  factory VehicleModel.fromBridgeCoreResponse(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int,
      name: json['name'] as String,
      seatCapacity: json['seat_capacity'] as int,
      licensePlate: json['license_plate'] as String?,
      driverId: _parseId(json['driver_id']),
      driverName: _parseName(json['driver_id']),
    );
  }

  /// تحويل إلى Entity
  VehicleEntity toEntity() {
    return VehicleEntity(
      id: id,
      name: name,
      seatCapacity: seatCapacity,
      licensePlate: licensePlate,
      driverId: driverId,
      driverName: driverName,
    );
  }

  /// Helper methods
  static int? _parseId(dynamic value) {
    if (value == null || value == false) return null;
    if (value is int) return value;
    if (value is List && value.isNotEmpty) return value[0] as int;
    return null;
  }

  static String? _parseName(dynamic value) {
    if (value == null || value == false) return null;
    if (value is String) return value;
    if (value is List && value.length > 1) return value[1] as String;
    return null;
  }
}
