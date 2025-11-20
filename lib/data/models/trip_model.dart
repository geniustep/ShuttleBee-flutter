import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';

part 'trip_model.freezed.dart';
part 'trip_model.g.dart';

/// نموذج الرحلة (Trip Model)
@freezed
class TripModel with _$TripModel {
  const TripModel._();

  const factory TripModel({
    required int id,
    required String name,
    required DateTime date,
    required TripType tripType,
    required TripState state,
    int? groupId,
    String? groupName,
    int? driverId,
    String? driverName,
    int? vehicleId,
    String? vehicleName,
    DateTime? plannedStartTime,
    DateTime? plannedArrivalTime,
    DateTime? actualStartTime,
    DateTime? actualArrivalTime,
    @Default(0) int totalPassengers,
    @Default(0) int presentCount,
    @Default(0) int absentCount,
    @Default(0) int boardedCount,
    @Default(0) int droppedCount,
    @Default(0.0) double occupancyRate,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastGpsUpdate,
  }) = _TripModel;

  /// من JSON
  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);

  /// من BridgeCore API Response
  factory TripModel.fromBridgeCoreResponse(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as int,
      name: _parseString(json['name']) ?? '',
      date: _parseDateTime(json['date']) ?? DateTime.now(),
      tripType: _parseTripType(json['trip_type']) ?? TripType.pickup,
      state: _parseTripState(json['state']) ?? TripState.draft,
      groupId: _parseId(json['group_id']),
      groupName: _parseName(json['group_id']),
      driverId: _parseId(json['driver_id']),
      driverName: _parseName(json['driver_id']),
      vehicleId: _parseId(json['vehicle_id']),
      vehicleName: _parseName(json['vehicle_id']),
      plannedStartTime: _parseDateTime(json['planned_start_time']),
      plannedArrivalTime: _parseDateTime(json['planned_arrival_time']),
      actualStartTime: _parseDateTime(json['actual_start_time']),
      actualArrivalTime: _parseDateTime(json['actual_arrival_time']),
      totalPassengers: json['total_passengers'] as int? ?? 0,
      presentCount: json['present_count'] as int? ?? 0,
      absentCount: json['absent_count'] as int? ?? 0,
      boardedCount: json['boarded_count'] as int? ?? 0,
      droppedCount: json['dropped_count'] as int? ?? 0,
      occupancyRate: (json['occupancy_rate'] as num?)?.toDouble() ?? 0.0,
      currentLatitude: (json['current_latitude'] as num?)?.toDouble(),
      currentLongitude: (json['current_longitude'] as num?)?.toDouble(),
      lastGpsUpdate: _parseDateTime(json['last_gps_update']),
    );
  }

  /// تحويل إلى Entity
  TripEntity toEntity() {
    return TripEntity(
      id: id,
      name: name,
      date: date,
      tripType: tripType,
      state: state,
      groupId: groupId,
      groupName: groupName,
      driverId: driverId,
      driverName: driverName,
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      plannedStartTime: plannedStartTime,
      plannedArrivalTime: plannedArrivalTime,
      actualStartTime: actualStartTime,
      actualArrivalTime: actualArrivalTime,
      totalPassengers: totalPassengers,
      presentCount: presentCount,
      absentCount: absentCount,
      boardedCount: boardedCount,
      droppedCount: droppedCount,
      occupancyRate: occupancyRate,
      currentLatitude: currentLatitude,
      currentLongitude: currentLongitude,
      lastGpsUpdate: lastGpsUpdate,
    );
  }

  /// Helper methods
  static int? _parseId(dynamic value) {
    if (value == null || value == false) return null;
    if (value is int) return value;
    if (value is List && value.isNotEmpty) return value[0] as int;
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null || value == false) return null;
    return value.toString();
  }

  static TripType? _parseTripType(dynamic value) {
    final str = _parseString(value);
    if (str == null || str.isEmpty) return null;
    try {
      return TripType.fromString(str);
    } catch (_) {
      return null;
    }
  }

  static TripState? _parseTripState(dynamic value) {
    final str = _parseString(value);
    if (str == null || str.isEmpty) return null;
    try {
      return TripState.fromString(str);
    } catch (_) {
      return null;
    }
  }

  static String? _parseName(dynamic value) {
    if (value == null || value == false) return null;
    if (value is String) return value;
    if (value is List && value.length > 1) return value[1] as String;
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null || value == false) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
