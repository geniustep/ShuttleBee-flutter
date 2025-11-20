import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/services/bridgecore_service.dart';
import 'package:shuttlebee/data/models/auth_model.dart';
import 'package:shuttlebee/data/models/user_model.dart';

/// مصدر البيانات البعيد للمصادقة
abstract class AuthRemoteDataSource {
  /// تسجيل الدخول
  Future<AuthModel> login({
    required String url,
    required String database,
    required String username,
    required String password,
  });

  /// تسجيل الخروج
  Future<void> logout();

  /// الحصول على المستخدم الحالي
  Future<UserModel> getCurrentUser();
}

/// تنفيذ AuthRemoteDataSource
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

      return AuthModel.fromJson(response);
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
}
