import 'package:equatable/equatable.dart';
import 'package:shuttlebee/core/enums/enums.dart';

/// كيان مجموعة الركاب (Passenger Group Entity)
class PassengerGroupEntity extends Equatable {
  const PassengerGroupEntity({
    required this.id,
    required this.name,
    required this.tripType,
    this.driverId,
    this.driverName,
    this.vehicleId,
    this.vehicleName,
    this.totalSeats = 0,
    this.passengerCount = 0,
    this.destinationStopId,
    this.destinationStopName,
    this.useCompanyDestination = false,
    this.autoScheduleEnabled = false,
    this.autoScheduleWeeks = 1,
  });

  final int id;
  final String name;
  final TripType tripType;
  final int? driverId;
  final String? driverName;
  final int? vehicleId;
  final String? vehicleName;
  final int totalSeats;
  final int passengerCount;
  final int? destinationStopId;
  final String? destinationStopName;
  final bool useCompanyDestination;
  final bool autoScheduleEnabled;
  final int autoScheduleWeeks;

  /// هل المجموعة لديها سائق
  bool get hasDriver => driverId != null;

  /// هل المجموعة لديها مركبة
  bool get hasVehicle => vehicleId != null;

  /// هل المجموعة لديها محطة وجهة
  bool get hasDestination => destinationStopId != null;

  /// نسبة الإشغال
  double get occupancyRate {
    if (totalSeats == 0) return 0.0;
    return passengerCount / totalSeats;
  }

  /// المقاعد المتاحة
  int get availableSeats => totalSeats - passengerCount;

  /// هل المجموعة ممتلئة
  bool get isFull => passengerCount >= totalSeats;

  @override
  List<Object?> get props => [
        id,
        name,
        tripType,
        driverId,
        driverName,
        vehicleId,
        vehicleName,
        totalSeats,
        passengerCount,
        destinationStopId,
        destinationStopName,
        useCompanyDestination,
        autoScheduleEnabled,
        autoScheduleWeeks,
      ];
}
