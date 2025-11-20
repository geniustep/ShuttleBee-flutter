import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/domain/entities/trip_line_entity.dart';

/// واجهة مستودع خطوط الرحلة (الركاب في الرحلة)
abstract class TripLineRepository {
  /// جلب قائمة خطوط الرحلة
  Future<Either<Failure, List<TripLineEntity>>> getTripLines({
    int? tripId,
    int? passengerId,
  });

  /// جلب خط رحلة بالـ ID
  Future<Either<Failure, TripLineEntity>> getTripLineById(int id);

  /// إنشاء خط رحلة جديد
  Future<Either<Failure, TripLineEntity>> createTripLine({
    required int tripId,
    required int passengerId,
    int? pickupStopId,
    int? dropoffStopId,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    int? sequence,
  });

  /// تحديث خط رحلة
  Future<Either<Failure, TripLineEntity>> updateTripLine({
    required int id,
    int? pickupStopId,
    int? dropoffStopId,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    int? sequence,
  });

  /// حذف خط رحلة
  Future<Either<Failure, void>> deleteTripLine(int id);

  /// وضع علامة "صعد" للراكب
  Future<Either<Failure, TripLineEntity>> markAsBoarded(int tripLineId);

  /// وضع علامة "غائب" للراكب
  Future<Either<Failure, TripLineEntity>> markAsAbsent(
    int tripLineId, {
    String? absenceReason,
  });

  /// وضع علامة "نزل" للراكب
  Future<Either<Failure, TripLineEntity>> markAsDropped(int tripLineId);
}
