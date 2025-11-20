import 'package:dartz/dartz.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/domain/entities/auth_entity.dart';
import 'package:shuttlebee/domain/entities/user_entity.dart';

/// واجهة مستودع المصادقة
abstract class AuthRepository {
  /// تسجيل الدخول
  Future<Either<Failure, AuthEntity>> login({
    required String url,
    required String database,
    required String username,
    required String password,
  });

  /// تسجيل الخروج
  Future<Either<Failure, void>> logout();

  /// الحصول على المستخدم الحالي
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// تحديث التوكن
  Future<Either<Failure, AuthEntity>> refreshToken();

  /// التحقق من حالة المصادقة
  Future<bool> isAuthenticated();

  /// الحصول على التوكن الحالي
  Future<String?> getAccessToken();

  /// حفظ التوكنات
  Future<void> saveTokens(AuthEntity auth);

  /// حذف التوكنات
  Future<void> clearTokens();
}
