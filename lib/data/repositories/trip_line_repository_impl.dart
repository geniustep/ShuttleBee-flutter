import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/core/network/network_info.dart';
import 'package:shuttlebee/data/datasources/remote/trip_line_remote_datasource.dart';
import 'package:shuttlebee/domain/entities/trip_line_entity.dart';
import 'package:shuttlebee/domain/repositories/trip_line_repository.dart';

/// تنفيذ TripLineRepository
class TripLineRepositoryImpl implements TripLineRepository {
  TripLineRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final TripLineRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<TripLineEntity>>> getTripLines({
    int? tripId,
    int? passengerId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final tripLineModels = await remoteDataSource.getTripLines(
        tripId: tripId,
        passengerId: passengerId,
      );

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
  Future<Either<Failure, TripLineEntity>> getTripLineById(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final tripLineModel = await remoteDataSource.getTripLineById(id);
      return Right(tripLineModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = {
        'trip_id': tripId,
        'passenger_id': passengerId,
        if (pickupStopId != null) 'pickup_stop_id': pickupStopId,
        if (dropoffStopId != null) 'dropoff_stop_id': dropoffStopId,
        if (pickupLatitude != null) 'pickup_latitude': pickupLatitude,
        if (pickupLongitude != null) 'pickup_longitude': pickupLongitude,
        if (dropoffLatitude != null) 'dropoff_latitude': dropoffLatitude,
        if (dropoffLongitude != null) 'dropoff_longitude': dropoffLongitude,
        if (sequence != null) 'sequence': sequence,
      };

      final tripLineModel = await remoteDataSource.createTripLine(data);
      return Right(tripLineModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, TripLineEntity>> updateTripLine({
    required int id,
    int? pickupStopId,
    int? dropoffStopId,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    int? sequence,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = <String, dynamic>{
        if (pickupStopId != null) 'pickup_stop_id': pickupStopId,
        if (dropoffStopId != null) 'dropoff_stop_id': dropoffStopId,
        if (pickupLatitude != null) 'pickup_latitude': pickupLatitude,
        if (pickupLongitude != null) 'pickup_longitude': pickupLongitude,
        if (dropoffLatitude != null) 'dropoff_latitude': dropoffLatitude,
        if (dropoffLongitude != null) 'dropoff_longitude': dropoffLongitude,
        if (sequence != null) 'sequence': sequence,
      };

      final tripLineModel = await remoteDataSource.updateTripLine(id, data);
      return Right(tripLineModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTripLine(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deleteTripLine(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, TripLineEntity>> markAsBoarded(int tripLineId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final tripLineModel = await remoteDataSource.markAsBoarded(tripLineId);
      return Right(tripLineModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, TripLineEntity>> markAsAbsent(
    int tripLineId, {
    String? absenceReason,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final tripLineModel = await remoteDataSource.markAsAbsent(
        tripLineId,
        absenceReason: absenceReason,
      );
      return Right(tripLineModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, TripLineEntity>> markAsDropped(int tripLineId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final tripLineModel = await remoteDataSource.markAsDropped(tripLineId);
      return Right(tripLineModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }
}
