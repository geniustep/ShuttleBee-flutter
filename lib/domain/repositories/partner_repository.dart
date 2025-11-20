import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/domain/entities/partner_entity.dart';

/// واجهة مستودع الشركاء (الركاب والسائقين)
abstract class PartnerRepository {
  /// جلب قائمة الشركاء
  Future<Either<Failure, List<PartnerEntity>>> getPartners({
    bool? isShuttlePassenger,
    bool? isDriver,
    int? limit,
    int? offset,
  });

  /// جلب شريك بالـ ID
  Future<Either<Failure, PartnerEntity>> getPartnerById(int id);

  /// البحث عن شركاء
  Future<Either<Failure, List<PartnerEntity>>> searchPartners(String query);

  /// إنشاء شريك جديد
  Future<Either<Failure, PartnerEntity>> createPartner({
    required String name,
    String? email,
    String? phone,
    String? mobile,
    bool? isShuttlePassenger,
    bool? isDriver,
    int? defaultPickupStopId,
    int? defaultDropoffStopId,
  });

  /// تحديث شريك
  Future<Either<Failure, PartnerEntity>> updatePartner({
    required int id,
    String? name,
    String? email,
    String? phone,
    String? mobile,
    bool? isShuttlePassenger,
    bool? isDriver,
    int? defaultPickupStopId,
    int? defaultDropoffStopId,
    double? shuttleLatitude,
    double? shuttleLongitude,
  });

  /// حذف شريك
  Future<Either<Failure, void>> deletePartner(int id);

  /// جلب جميع الركاب
  Future<Either<Failure, List<PartnerEntity>>> getPassengers({
    int? limit,
    int? offset,
  });

  /// جلب جميع السائقين
  Future<Either<Failure, List<PartnerEntity>>> getDrivers({
    int? limit,
    int? offset,
  });
}
