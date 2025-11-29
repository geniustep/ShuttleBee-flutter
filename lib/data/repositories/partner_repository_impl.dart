import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/constants/odoo_constants.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/core/network/network_info.dart';
import 'package:shuttlebee/data/datasources/remote/partner_remote_datasource.dart';
import 'package:shuttlebee/domain/entities/partner_entity.dart';
import 'package:shuttlebee/domain/repositories/partner_repository.dart';

/// تنفيذ PartnerRepository
class PartnerRepositoryImpl implements PartnerRepository {
  PartnerRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final PartnerRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<PartnerEntity>>> getPartners({
    bool? isShuttlePassenger,
    bool? isDriver,
    int? limit,
    int? offset,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final partnerModels = await remoteDataSource.getPartners(
        isShuttlePassenger: isShuttlePassenger,
        isDriver: isDriver,
        limit: limit,
        offset: offset,
      );

      return Right(partnerModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, PartnerEntity>> getPartnerById(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final partnerModel = await remoteDataSource.getPartnerById(id);
      return Right(partnerModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<PartnerEntity>>> searchPartners(
    String query,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final partnerModels = await remoteDataSource.searchPartners(query);
      return Right(partnerModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, PartnerEntity>> createPartner({
    required String name,
    String? email,
    String? phone,
    String? mobile,
    bool? isShuttlePassenger,
    bool? isDriver,
    int? defaultPickupStopId,
    int? defaultDropoffStopId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = {
        OdooConstants.fieldName: name,
        if (email != null) OdooConstants.fieldEmail: email,
        if (phone != null) OdooConstants.fieldPhone: phone,
        if (mobile != null) OdooConstants.fieldMobile: mobile,
        if (isShuttlePassenger != null)
          OdooConstants.fieldIsShuttlePassenger: isShuttlePassenger,
        if (isDriver != null) OdooConstants.fieldIsDriver: isDriver,
        if (defaultPickupStopId != null)
          OdooConstants.fieldDefaultPickupStopId: defaultPickupStopId,
        if (defaultDropoffStopId != null)
          OdooConstants.fieldDefaultDropoffStopId: defaultDropoffStopId,
      };

      final partnerModel = await remoteDataSource.createPartner(data);
      return Right(partnerModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = <String, dynamic>{
        if (name != null) OdooConstants.fieldName: name,
        if (email != null) OdooConstants.fieldEmail: email,
        if (phone != null) OdooConstants.fieldPhone: phone,
        if (mobile != null) OdooConstants.fieldMobile: mobile,
        if (isShuttlePassenger != null)
          OdooConstants.fieldIsShuttlePassenger: isShuttlePassenger,
        if (isDriver != null) OdooConstants.fieldIsDriver: isDriver,
        if (defaultPickupStopId != null)
          OdooConstants.fieldDefaultPickupStopId: defaultPickupStopId,
        if (defaultDropoffStopId != null)
          OdooConstants.fieldDefaultDropoffStopId: defaultDropoffStopId,
        if (shuttleLatitude != null)
          OdooConstants.fieldShuttleLatitude: shuttleLatitude,
        if (shuttleLongitude != null)
          OdooConstants.fieldShuttleLongitude: shuttleLongitude,
      };

      final partnerModel = await remoteDataSource.updatePartner(id, data);
      return Right(partnerModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deletePartner(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deletePartner(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<PartnerEntity>>> getPassengers({
    int? limit,
    int? offset,
  }) async {
    return getPartners(
      isShuttlePassenger: true,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Either<Failure, List<PartnerEntity>>> getDrivers({
    int? limit,
    int? offset,
  }) async {
    return getPartners(
      isDriver: true,
      limit: limit,
      offset: offset,
    );
  }
}

