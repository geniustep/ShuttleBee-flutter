import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shuttlebee/core/constants/app_constants.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/data/models/auth_model.dart';
import 'package:shuttlebee/data/models/user_model.dart';

/// مصدر البيانات المحلي للمصادقة
abstract class AuthLocalDataSource {
  /// حفظ التوكنات
  Future<void> saveTokens(AuthModel auth);

  /// جلب Access Token
  Future<String?> getAccessToken();

  /// جلب Refresh Token
  Future<String?> getRefreshToken();

  /// حذف التوكنات
  Future<void> clearTokens();

  /// حفظ بيانات المستخدم
  Future<void> cacheUser(UserModel user);

  /// جلب بيانات المستخدم المحفوظة
  Future<UserModel?> getCachedUser();

  /// حذف بيانات المستخدم
  Future<void> clearCachedUser();

  /// التحقق من وجود توكن
  Future<bool> hasToken();
}

/// تنفيذ AuthLocalDataSource
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> saveTokens(AuthModel auth) async {
    try {
      // حفظ Access Token
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: auth.accessToken,
      );
      
      // التحقق من أن التوكن تم حفظه
      final savedToken = await _secureStorage.read(
        key: AppConstants.accessTokenKey,
      );
      
      if (savedToken == null || savedToken != auth.accessToken) {
        throw CacheException('فشل التحقق من حفظ Access Token');
      }

      // حفظ Refresh Token
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: auth.refreshToken,
      );
    } catch (e) {
      throw CacheException('فشل حفظ التوكنات: ${e.toString()}');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      throw CacheException('فشل جلب Access Token');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw CacheException('فشل جلب Refresh Token');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: AppConstants.accessTokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw CacheException('فشل حذف التوكنات');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _secureStorage.write(
        key: AppConstants.userDataKey,
        value: userJson,
      );
    } catch (e) {
      throw CacheException('فشل حفظ بيانات المستخدم');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = await _secureStorage.read(
        key: AppConstants.userDataKey,
      );

      if (userJson == null) return null;

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await _secureStorage.delete(key: AppConstants.userDataKey);
    } catch (e) {
      throw CacheException('فشل حذف بيانات المستخدم');
    }
  }

  @override
  Future<bool> hasToken() async {
    try {
      final token = await _secureStorage.read(
        key: AppConstants.accessTokenKey,
      );
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
