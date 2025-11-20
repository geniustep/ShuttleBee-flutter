import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/domain/entities/passenger_group_entity.dart';

part 'passenger_group_model.freezed.dart';
part 'passenger_group_model.g.dart';

/// نموذج مجموعة الركاب (Passenger Group Model)
@freezed
class PassengerGroupModel with _$PassengerGroupModel {
  const PassengerGroupModel._();

  const factory PassengerGroupModel({
    required int id,
    required String name,
    required TripType tripType,
    int? driverId,
    String? driverName,
    int? vehicleId,
    String? vehicleName,
    @Default(0) int totalSeats,
    @Default(0) int passengerCount,
    int? destinationStopId,
    String? destinationStopName,
    @Default(false) bool useCompanyDestination,
    @Default(false) bool autoScheduleEnabled,
    @Default(1) int autoScheduleWeeks,
  }) = _PassengerGroupModel;

  /// من JSON
  factory PassengerGroupModel.fromJson(Map<String, dynamic> json) =>
      _$PassengerGroupModelFromJson(json);

  /// من BridgeCore API Response
  factory PassengerGroupModel.fromBridgeCoreResponse(
    Map<String, dynamic> json,
  ) {
    return PassengerGroupModel(
      id: json['id'] as int,
      name: json['name'] as String,
      tripType: TripType.fromString(json['trip_type'] as String),
      driverId: _parseId(json['driver_id']),
      driverName: _parseName(json['driver_id']),
      vehicleId: _parseId(json['vehicle_id']),
      vehicleName: _parseName(json['vehicle_id']),
      totalSeats: json['total_seats'] as int? ?? 0,
      passengerCount: json['passenger_count'] as int? ?? 0,
      destinationStopId: _parseId(json['destination_stop_id']),
      destinationStopName: _parseName(json['destination_stop_id']),
      useCompanyDestination: json['use_company_destination'] as bool? ?? false,
      autoScheduleEnabled: json['auto_schedule_enabled'] as bool? ?? false,
      autoScheduleWeeks: json['auto_schedule_weeks'] as int? ?? 1,
    );
  }

  /// تحويل إلى Entity
  PassengerGroupEntity toEntity() {
    return PassengerGroupEntity(
      id: id,
      name: name,
      tripType: tripType,
      driverId: driverId,
      driverName: driverName,
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      totalSeats: totalSeats,
      passengerCount: passengerCount,
      destinationStopId: destinationStopId,
      destinationStopName: destinationStopName,
      useCompanyDestination: useCompanyDestination,
      autoScheduleEnabled: autoScheduleEnabled,
      autoScheduleWeeks: autoScheduleWeeks,
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
