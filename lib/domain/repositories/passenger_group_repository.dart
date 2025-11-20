import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/domain/entities/passenger_group_entity.dart';

/// واجهة مستودع مجموعات الركاب
abstract class PassengerGroupRepository {
  /// جلب قائمة المجموعات
  Future<Either<Failure, List<PassengerGroupEntity>>> getPassengerGroups({
    TripType? tripType,
    int? driverId,
    int? vehicleId,
    int? limit,
    int? offset,
  });

  /// جلب مجموعة بالـ ID
  Future<Either<Failure, PassengerGroupEntity>> getPassengerGroupById(int id);

  /// البحث عن مجموعات
  Future<Either<Failure, List<PassengerGroupEntity>>> searchPassengerGroups(
    String query,
  );

  /// إنشاء مجموعة جديدة
  Future<Either<Failure, PassengerGroupEntity>> createPassengerGroup({
    required String name,
    required TripType tripType,
    int? driverId,
    int? vehicleId,
    int? totalSeats,
    int? destinationStopId,
    bool? useCompanyDestination,
    bool? autoScheduleEnabled,
    int? autoScheduleWeeks,
  });

  /// تحديث مجموعة
  Future<Either<Failure, PassengerGroupEntity>> updatePassengerGroup({
    required int id,
    String? name,
    TripType? tripType,
    int? driverId,
    int? vehicleId,
    int? totalSeats,
    int? destinationStopId,
    bool? useCompanyDestination,
    bool? autoScheduleEnabled,
    int? autoScheduleWeeks,
  });

  /// حذف مجموعة
  Future<Either<Failure, void>> deletePassengerGroup(int id);

  /// إضافة راكب لمجموعة
  Future<Either<Failure, void>> addPassengerToGroup({
    required int groupId,
    required int passengerId,
  });

  /// إزالة راكب من مجموعة
  Future<Either<Failure, void>> removePassengerFromGroup({
    required int groupId,
    required int passengerId,
  });
}
