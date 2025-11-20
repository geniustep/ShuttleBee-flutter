import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/domain/entities/vehicle_entity.dart';

/// واجهة مستودع المركبات
abstract class VehicleRepository {
  /// جلب قائمة المركبات
  Future<Either<Failure, List<VehicleEntity>>> getVehicles({
    int? driverId,
    int? limit,
    int? offset,
  });

  /// جلب مركبة بالـ ID
  Future<Either<Failure, VehicleEntity>> getVehicleById(int id);

  /// البحث عن مركبات
  Future<Either<Failure, List<VehicleEntity>>> searchVehicles(String query);

  /// إنشاء مركبة جديدة
  Future<Either<Failure, VehicleEntity>> createVehicle({
    required String name,
    required int seatCapacity,
    String? licensePlate,
    int? driverId,
  });

  /// تحديث مركبة
  Future<Either<Failure, VehicleEntity>> updateVehicle({
    required int id,
    String? name,
    int? seatCapacity,
    String? licensePlate,
    int? driverId,
  });

  /// حذف مركبة
  Future<Either<Failure, void>> deleteVehicle(int id);

  /// جلب المركبات المتاحة (بدون سائق)
  Future<Either<Failure, List<VehicleEntity>>> getAvailableVehicles();
}
