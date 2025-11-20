import 'package:equatable/equatable.dart';
import 'package:shuttlebee/core/enums/enums.dart';

/// كيان الرحلة (Trip Entity)
class TripEntity extends Equatable {
  const TripEntity({
    required this.id,
    required this.name,
    required this.date,
    required this.tripType,
    required this.state,
    this.groupId,
    this.groupName,
    this.driverId,
    this.driverName,
    this.vehicleId,
    this.vehicleName,
    this.plannedStartTime,
    this.plannedArrivalTime,
    this.actualStartTime,
    this.actualArrivalTime,
    this.totalPassengers = 0,
    this.presentCount = 0,
    this.absentCount = 0,
    this.boardedCount = 0,
    this.droppedCount = 0,
    this.occupancyRate = 0.0,
    this.currentLatitude,
    this.currentLongitude,
    this.lastGpsUpdate,
  });

  final int id;
  final String name;
  final DateTime date;
  final TripType tripType;
  final TripState state;
  final int? groupId;
  final String? groupName;
  final int? driverId;
  final String? driverName;
  final int? vehicleId;
  final String? vehicleName;
  final DateTime? plannedStartTime;
  final DateTime? plannedArrivalTime;
  final DateTime? actualStartTime;
  final DateTime? actualArrivalTime;
  final int totalPassengers;
  final int presentCount;
  final int absentCount;
  final int boardedCount;
  final int droppedCount;
  final double occupancyRate;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? lastGpsUpdate;

  /// هل الرحلة نشطة
  bool get isOngoing => state.isOngoing;

  /// هل الرحلة منتهية
  bool get isCompleted => state.isCompleted;

  /// هل يمكن بدء الرحلة
  bool get canStart => state.canStart;

  /// هل يمكن إنهاء الرحلة
  bool get canComplete => state.canComplete;

  /// هل يمكن إلغاء الرحلة
  bool get canCancel => state.canCancel;

  /// هل يوجد موقع GPS حالي
  bool get hasCurrentLocation =>
      currentLatitude != null && currentLongitude != null;

  /// نسبة الاكتمال
  double get completionPercentage {
    if (totalPassengers == 0) return 0.0;
    return (boardedCount + droppedCount + absentCount) / totalPassengers;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        date,
        tripType,
        state,
        groupId,
        groupName,
        driverId,
        driverName,
        vehicleId,
        vehicleName,
        plannedStartTime,
        plannedArrivalTime,
        actualStartTime,
        actualArrivalTime,
        totalPassengers,
        presentCount,
        absentCount,
        boardedCount,
        droppedCount,
        occupancyRate,
        currentLatitude,
        currentLongitude,
        lastGpsUpdate,
      ];
}
