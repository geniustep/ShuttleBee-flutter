import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/domain/entities/stop_entity.dart';

/// واجهة مستودع المحطات
abstract class StopRepository {
  /// جلب قائمة المحطات
  Future<Either<Failure, List<StopEntity>>> getStops({
    StopType? stopType,
    String? city,
    int? limit,
    int? offset,
  });

  /// جلب محطة بالـ ID
  Future<Either<Failure, StopEntity>> getStopById(int id);

  /// البحث عن محطات
  Future<Either<Failure, List<StopEntity>>> searchStops(String query);

  /// إنشاء محطة جديدة
  Future<Either<Failure, StopEntity>> createStop({
    required String name,
    required StopType stopType,
    required double latitude,
    required double longitude,
    String? address,
    String? city,
  });

  /// تحديث محطة
  Future<Either<Failure, StopEntity>> updateStop({
    required int id,
    String? name,
    StopType? stopType,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
  });

  /// حذف محطة
  Future<Either<Failure, void>> deleteStop(int id);

  /// اقتراح أقرب المحطات
  Future<Either<Failure, List<StopEntity>>> suggestNearestStops({
    required double latitude,
    required double longitude,
    StopType? stopType,
    int limit = 5,
  });
}
