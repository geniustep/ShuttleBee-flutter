import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/constants/odoo_constants.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/core/network/network_info.dart';
import 'package:shuttlebee/data/datasources/remote/vehicle_remote_datasource.dart';
import 'package:shuttlebee/domain/entities/vehicle_entity.dart';
import 'package:shuttlebee/domain/repositories/vehicle_repository.dart';

/// تنفيذ VehicleRepository
class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final VehicleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<VehicleEntity>>> getVehicles({
    int? driverId,
    int? limit,
    int? offset,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final vehicleModels = await remoteDataSource.getVehicles(
        driverId: driverId,
        limit: limit,
        offset: offset,
      );

      return Right(vehicleModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> getVehicleById(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final vehicleModel = await remoteDataSource.getVehicleById(id);
      return Right(vehicleModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> searchVehicles(
    String query,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final vehicleModels = await remoteDataSource.searchVehicles(query);
      return Right(vehicleModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> createVehicle({
    required String name,
    required int seatCapacity,
    String? licensePlate,
    int? driverId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = {
        OdooConstants.fieldName: name,
        OdooConstants.fieldSeatCapacity: seatCapacity,
        if (licensePlate != null)
          OdooConstants.fieldLicensePlate: licensePlate,
        if (driverId != null) OdooConstants.fieldDriverId: driverId,
      };

      final vehicleModel = await remoteDataSource.createVehicle(data);
      return Right(vehicleModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> updateVehicle({
    required int id,
    String? name,
    int? seatCapacity,
    String? licensePlate,
    int? driverId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = <String, dynamic>{
        if (name != null) OdooConstants.fieldName: name,
        if (seatCapacity != null)
          OdooConstants.fieldSeatCapacity: seatCapacity,
        if (licensePlate != null)
          OdooConstants.fieldLicensePlate: licensePlate,
        if (driverId != null) OdooConstants.fieldDriverId: driverId,
      };

      final vehicleModel = await remoteDataSource.updateVehicle(id, data);
      return Right(vehicleModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVehicle(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deleteVehicle(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getAvailableVehicles() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      // المركبات المتاحة هي التي لا تحتوي على driver_id
      final vehicleModels = await remoteDataSource.getVehicles(
        driverId: null,
      );

      // تصفية المركبات التي لا تحتوي على سائق
      final availableVehicles = vehicleModels
          .where((v) => v.driverId == null)
          .map((model) => model.toEntity())
          .toList();

      return Right(availableVehicles);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }
}

