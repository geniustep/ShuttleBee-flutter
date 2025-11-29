import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/constants/odoo_constants.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/core/network/network_info.dart';
import 'package:shuttlebee/data/datasources/remote/passenger_group_remote_datasource.dart';
import 'package:shuttlebee/domain/entities/passenger_group_entity.dart';
import 'package:shuttlebee/domain/repositories/passenger_group_repository.dart';

/// تنفيذ PassengerGroupRepository
class PassengerGroupRepositoryImpl implements PassengerGroupRepository {
  PassengerGroupRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final PassengerGroupRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<PassengerGroupEntity>>> getPassengerGroups({
    TripType? tripType,
    int? driverId,
    int? vehicleId,
    int? limit,
    int? offset,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final groupModels = await remoteDataSource.getPassengerGroups(
        tripType: tripType,
        driverId: driverId,
        vehicleId: vehicleId,
        limit: limit,
        offset: offset,
      );

      return Right(groupModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, PassengerGroupEntity>> getPassengerGroupById(
      int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final groupModel = await remoteDataSource.getPassengerGroupById(id);
      return Right(groupModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<PassengerGroupEntity>>> searchPassengerGroups(
    String query,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final groupModels = await remoteDataSource.searchPassengerGroups(query);
      return Right(groupModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = {
        OdooConstants.fieldName: name,
        OdooConstants.fieldTripType: tripType.value,
        if (driverId != null) OdooConstants.fieldDriverId: driverId,
        if (vehicleId != null) OdooConstants.fieldVehicleId: vehicleId,
        if (totalSeats != null) OdooConstants.fieldTotalSeats: totalSeats,
        if (destinationStopId != null)
          OdooConstants.fieldDestinationStopId: destinationStopId,
        if (useCompanyDestination != null)
          OdooConstants.fieldUseCompanyDestination: useCompanyDestination,
        if (autoScheduleEnabled != null)
          OdooConstants.fieldAutoScheduleEnabled: autoScheduleEnabled,
        if (autoScheduleWeeks != null)
          OdooConstants.fieldAutoScheduleWeeks: autoScheduleWeeks,
      };

      final groupModel = await remoteDataSource.createPassengerGroup(data);
      return Right(groupModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = <String, dynamic>{
        if (name != null) OdooConstants.fieldName: name,
        if (tripType != null) OdooConstants.fieldTripType: tripType.value,
        if (driverId != null) OdooConstants.fieldDriverId: driverId,
        if (vehicleId != null) OdooConstants.fieldVehicleId: vehicleId,
        if (totalSeats != null) OdooConstants.fieldTotalSeats: totalSeats,
        if (destinationStopId != null)
          OdooConstants.fieldDestinationStopId: destinationStopId,
        if (useCompanyDestination != null)
          OdooConstants.fieldUseCompanyDestination: useCompanyDestination,
        if (autoScheduleEnabled != null)
          OdooConstants.fieldAutoScheduleEnabled: autoScheduleEnabled,
        if (autoScheduleWeeks != null)
          OdooConstants.fieldAutoScheduleWeeks: autoScheduleWeeks,
      };

      final groupModel =
          await remoteDataSource.updatePassengerGroup(id, data);
      return Right(groupModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deletePassengerGroup(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deletePassengerGroup(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> addPassengerToGroup({
    required int groupId,
    required int passengerId,
  }) async {
    // TODO: Implement add passenger to group
    // This might require a custom Odoo method
    return const Left(ServerFailure('Not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> removePassengerFromGroup({
    required int groupId,
    required int passengerId,
  }) async {
    // TODO: Implement remove passenger from group
    // This might require a custom Odoo method
    return const Left(ServerFailure('Not implemented yet'));
  }
}

