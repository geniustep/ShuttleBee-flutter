import 'package:equatable/equatable.dart';
import 'package:shuttlebee/core/enums/enums.dart';

/// كيان خط الرحلة - الراكب في الرحلة (Trip Line Entity)
class TripLineEntity extends Equatable {
  const TripLineEntity({
    required this.id,
    required this.tripId,
    this.tripName,
    required this.passengerId,
    required this.passengerName,
    this.passengerPhone,
    this.pickupStopId,
    this.pickupStopName,
    this.dropoffStopId,
    this.dropoffStopName,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    required this.status,
    this.boardingTime,
    this.dropoffTime,
    this.absenceReason,
    this.sequence = 0,
  });

  final int id;
  final int tripId;
  final String? tripName;
  final int passengerId;
  final String passengerName;
  final String? passengerPhone;
  final int? pickupStopId;
  final String? pickupStopName;
  final int? dropoffStopId;
  final String? dropoffStopName;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final TripLineStatus status;
  final DateTime? boardingTime;
  final DateTime? dropoffTime;
  final String? absenceReason;
  final int sequence;

  /// هل الراكب على متن الحافلة
  bool get isOnBoard => status.isOnBoard;

  /// هل الراكب نزل
  bool get isDropped => status.isDropped;

  /// هل الراكب غائب
  bool get isAbsent => status.isAbsent;

  /// هل يمكن وضع علامة صعد
  bool get canMarkBoarded => status.canMarkBoarded;

  /// هل يمكن وضع علامة غائب
  bool get canMarkAbsent => status.canMarkAbsent;

  /// هل يمكن وضع علامة نزل
  bool get canMarkDropped => status.canMarkDropped;

  /// هل يوجد موقع استقبال
  bool get hasPickupLocation =>
      pickupLatitude != null && pickupLongitude != null;

  /// هل يوجد موقع توصيل
  bool get hasDropoffLocation =>
      dropoffLatitude != null && dropoffLongitude != null;

  @override
  List<Object?> get props => [
        id,
        tripId,
        tripName,
        passengerId,
        passengerName,
        passengerPhone,
        pickupStopId,
        pickupStopName,
        dropoffStopId,
        dropoffStopName,
        pickupLatitude,
        pickupLongitude,
        dropoffLatitude,
        dropoffLongitude,
        status,
        boardingTime,
        dropoffTime,
        absenceReason,
        sequence,
      ];
}
