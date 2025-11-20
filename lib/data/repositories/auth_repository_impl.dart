import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/core/network/network_info.dart';
import 'package:shuttlebee/data/datasources/local/auth_local_datasource.dart';
import 'package:shuttlebee/data/datasources/remote/auth_remote_datasource.dart';
import 'package:shuttlebee/domain/entities/auth_entity.dart';
import 'package:shuttlebee/domain/entities/user_entity.dart';
import 'package:shuttlebee/domain/repositories/auth_repository.dart';

/// AuthRepository implementation
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String url,
    required String database,
    required String username,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final authModel = await remoteDataSource.login(
        url: url,
        database: database,
        username: username,
        password: password,
      );

      // Save tokens then connect system using bearer
      await localDataSource.saveTokens(authModel);
      await remoteDataSource.connectSystem(
        url: url,
        database: database,
        username: username,
        password: password,
      );

      return Right(authModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }

      await localDataSource.clearTokens();
      await localDataSource.clearCachedUser();

      return const Right(null);
    } on ServerException catch (e) {
      await localDataSource.clearTokens();
      await localDataSource.clearCachedUser();
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    if (!await networkInfo.isConnected) {
      try {
        final cachedUser = await localDataSource.getCachedUser();
        if (cachedUser != null) {
          return Right(cachedUser.toEntity());
        }
        return const Left(NetworkFailure());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }

    try {
      final userModel = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> refreshToken() async {
    return const Left(
      ServerFailure('Token refresh is handled automatically'),
    );
  }

  @override
  Future<bool> isAuthenticated() async {
    return localDataSource.hasToken();
  }

  @override
  Future<String?> getAccessToken() async {
    return localDataSource.getAccessToken();
  }

  @override
  Future<void> saveTokens(AuthEntity auth) async {
    throw UnimplementedError('Use login method instead');
  }

  @override
  Future<void> clearTokens() async {
    await localDataSource.clearTokens();
  }
}
