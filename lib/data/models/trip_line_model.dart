import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/domain/entities/trip_line_entity.dart';

part 'trip_line_model.freezed.dart';
part 'trip_line_model.g.dart';

/// نموذج خط الرحلة - الراكب في الرحلة (Trip Line Model)
@freezed
class TripLineModel with _$TripLineModel {
  const TripLineModel._();

  const factory TripLineModel({
    required int id,
    required int tripId,
    String? tripName,
    required int passengerId,
    required String passengerName,
    String? passengerPhone,
    int? pickupStopId,
    String? pickupStopName,
    int? dropoffStopId,
    String? dropoffStopName,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    required TripLineStatus status,
    DateTime? boardingTime,
    DateTime? dropoffTime,
    String? absenceReason,
    @Default(0) int sequence,
  }) = _TripLineModel;

  /// من JSON
  factory TripLineModel.fromJson(Map<String, dynamic> json) =>
      _$TripLineModelFromJson(json);

  /// من BridgeCore API Response
  factory TripLineModel.fromBridgeCoreResponse(Map<String, dynamic> json) {
    return TripLineModel(
      id: json['id'] as int,
      tripId: _parseId(json['trip_id']) ?? 0,
      tripName: _parseName(json['trip_id']),
      passengerId: _parseId(json['passenger_id']) ?? 0,
      passengerName: _parseName(json['passenger_id']) ?? '',
      passengerPhone: json['passenger_phone'] as String?,
      pickupStopId: _parseId(json['pickup_stop_id']),
      pickupStopName: _parseName(json['pickup_stop_id']),
      dropoffStopId: _parseId(json['dropoff_stop_id']),
      dropoffStopName: _parseName(json['dropoff_stop_id']),
      pickupLatitude: (json['pickup_latitude'] as num?)?.toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num?)?.toDouble(),
      dropoffLatitude: (json['dropoff_latitude'] as num?)?.toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num?)?.toDouble(),
      status: TripLineStatus.fromString(json['status'] as String),
      boardingTime: _parseDateTime(json['boarding_time']),
      dropoffTime: _parseDateTime(json['dropoff_time']),
      absenceReason: json['absence_reason'] as String?,
      sequence: json['sequence'] as int? ?? 0,
    );
  }

  /// تحويل إلى Entity
  TripLineEntity toEntity() {
    return TripLineEntity(
      id: id,
      tripId: tripId,
      tripName: tripName,
      passengerId: passengerId,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      pickupStopId: pickupStopId,
      pickupStopName: pickupStopName,
      dropoffStopId: dropoffStopId,
      dropoffStopName: dropoffStopName,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      dropoffLatitude: dropoffLatitude,
      dropoffLongitude: dropoffLongitude,
      status: status,
      boardingTime: boardingTime,
      dropoffTime: dropoffTime,
      absenceReason: absenceReason,
      sequence: sequence,
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
