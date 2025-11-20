import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';
import 'package:shuttlebee/domain/entities/trip_line_entity.dart';

/// واجهة مستودع الرحلات
abstract class TripRepository {
  /// جلب قائمة الرحلات
  Future<Either<Failure, List<TripEntity>>> getTrips({
    DateTime? dateFrom,
    DateTime? dateTo,
    TripState? state,
    int? driverId,
    int? groupId,
    int? limit,
    int? offset,
  });

  /// جلب رحلة بالـ ID
  Future<Either<Failure, TripEntity>> getTripById(int id);

  /// إنشاء رحلة جديدة
  Future<Either<Failure, TripEntity>> createTrip({
    required String name,
    required DateTime date,
    required TripType tripType,
    required int groupId,
    int? driverId,
    int? vehicleId,
    DateTime? plannedStartTime,
    DateTime? plannedArrivalTime,
  });

  /// تحديث رحلة
  Future<Either<Failure, TripEntity>> updateTrip({
    required int id,
    String? name,
    DateTime? date,
    TripType? tripType,
    int? groupId,
    int? driverId,
    int? vehicleId,
    DateTime? plannedStartTime,
    DateTime? plannedArrivalTime,
  });

  /// حذف رحلة
  Future<Either<Failure, void>> deleteTrip(int id);

  /// بدء رحلة
  Future<Either<Failure, TripEntity>> startTrip(int tripId);

  /// إنهاء رحلة
  Future<Either<Failure, TripEntity>> completeTrip(int tripId);

  /// إلغاء رحلة
  Future<Either<Failure, TripEntity>> cancelTrip(int tripId);

  /// تسجيل موقع GPS
  Future<Either<Failure, void>> registerGpsPosition({
    required int tripId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
  });

  /// إرسال إشعارات الاقتراب
  Future<Either<Failure, void>> sendApproachingNotifications(int tripId);

  /// إرسال إشعارات الوصول
  Future<Either<Failure, void>> sendArrivedNotifications(int tripId);

  /// جلب إحصائيات Dashboard
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats({
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  /// جلب خطوط الرحلة (الركاب)
  Future<Either<Failure, List<TripLineEntity>>> getTripLines(int tripId);

  /// جلب رحلات السائق اليومية
  Future<Either<Failure, List<TripEntity>>> getDriverDailyTrips(
    int driverId,
    DateTime date,
  );

  /// جلب رحلات الراكب
  Future<Either<Failure, List<TripEntity>>> getPassengerTrips(
    int passengerId, {
    DateTime? dateFrom,
    DateTime? dateTo,
  });
}
