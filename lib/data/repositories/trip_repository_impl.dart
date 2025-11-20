import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/core/network/network_info.dart';
import 'package:shuttlebee/data/datasources/remote/trip_remote_datasource.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';
import 'package:shuttlebee/domain/entities/trip_line_entity.dart';
import 'package:shuttlebee/domain/repositories/trip_repository.dart';

/// تنفيذ TripRepository
class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final TripRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<TripEntity>>> getTrips({
    DateTime? dateFrom,
    DateTime? dateTo,
    TripState? state,
    int? driverId,
    int? groupId,
    int? limit,
    int? offset,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final tripModels = await remoteDataSource.getTrips(
        dateFrom: dateFrom,
        dateTo: dateTo,
        state: state,
        driverId: driverId,
        groupId: groupId,
        limit: limit,
        offset: offset,
      );

      return Right(tripModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> getTripById(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final tripModel = await remoteDataSource.getTripById(id);
      return Right(tripModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> createTrip({
    required String name,
    required DateTime date,
    required TripType tripType,
    required int groupId,
    int? driverId,
    int? vehicleId,
    DateTime? plannedStartTime,
    DateTime? plannedArrivalTime,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = {
        'name': name,
        'date': date.toIso8601String().split('T').first,
        'trip_type': tripType.value,
        'group_id': groupId,
        if (driverId != null) 'driver_id': driverId,
        if (vehicleId != null) 'vehicle_id': vehicleId,
        if (plannedStartTime != null)
          'planned_start_time': plannedStartTime.toIso8601String(),
        if (plannedArrivalTime != null)
          'planned_arrival_time': plannedArrivalTime.toIso8601String(),
      };

      final tripModel = await remoteDataSource.createTrip(data);
      return Right(tripModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = <String, dynamic>{
        if (name != null) 'name': name,
        if (date != null) 'date': date.toIso8601String().split('T').first,
        if (tripType != null) 'trip_type': tripType.value,
        if (groupId != null) 'group_id': groupId,
        if (driverId != null) 'driver_id': driverId,
        if (vehicleId != null) 'vehicle_id': vehicleId,
        if (plannedStartTime != null)
          'planned_start_time': plannedStartTime.toIso8601String(),
        if (plannedArrivalTime != null)
          'planned_arrival_time': plannedArrivalTime.toIso8601String(),
      };

      final tripModel = await remoteDataSource.updateTrip(id, data);
      return Right(tripModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrip(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deleteTrip(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> startTrip(int tripId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final tripModel = await remoteDataSource.startTrip(tripId);
      return Right(tripModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> completeTrip(int tripId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final tripModel = await remoteDataSource.completeTrip(tripId);
      return Right(tripModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> cancelTrip(int tripId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final tripModel = await remoteDataSource.cancelTrip(tripId);
      return Right(tripModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> registerGpsPosition({
    required int tripId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.registerGpsPosition(
        tripId: tripId,
        latitude: latitude,
        longitude: longitude,
        speed: speed,
        heading: heading,
        timestamp: timestamp,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendApproachingNotifications(
    int tripId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.sendApproachingNotifications(tripId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendArrivedNotifications(int tripId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.sendArrivedNotifications(tripId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final stats = await remoteDataSource.getDashboardStats(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<TripLineEntity>>> getTripLines(
    int tripId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final tripLineModels = await remoteDataSource.getTripLines(tripId);
      return Right(
        tripLineModels.map((model) => model.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getDriverDailyTrips(
    int driverId,
    DateTime date,
  ) async {
    return getTrips(
      driverId: driverId,
      dateFrom: date,
      dateTo: date,
    );
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getPassengerTrips(
    int passengerId, {
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    // TODO: Implement passenger-specific trip fetching
    // This might require a different search domain or custom method
    return getTrips(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
