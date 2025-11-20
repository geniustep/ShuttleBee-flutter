import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/services/bridgecore_service.dart';
import 'package:shuttlebee/data/models/auth_model.dart';
import 'package:shuttlebee/data/models/user_model.dart';

/// Remote auth data source
abstract class AuthRemoteDataSource {
  Future<AuthModel> login({
    required String url,
    required String database,
    required String username,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();

  Future<void> connectSystem({
    required String url,
    required String database,
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._bridgeCoreService);

  final BridgeCoreService _bridgeCoreService;

  @override
  Future<AuthModel> login({
    required String url,
    required String database,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _bridgeCoreService.login(
        url: url,
        database: database,
        username: username,
        password: password,
      );

      return AuthModel(
        accessToken: response['access_token'] as String,
        refreshToken: response['refresh_token'] as String,
        tokenType: (response['token_type'] as String?) ?? 'Bearer',
        expiresIn: (response['expires_in'] as int?) ?? 0,
        systemId: response['system_id'] as String?,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _bridgeCoreService.logout();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _bridgeCoreService.getCurrentUser();
      return UserModel.fromBridgeCoreResponse(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> connectSystem({
    required String url,
    required String database,
    required String username,
    required String password,
  }) async {
    try {
      await _bridgeCoreService.connectSystem(
        url: url,
        database: database,
        username: username,
        password: password,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
