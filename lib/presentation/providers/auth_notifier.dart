import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/di/injection.dart';
import 'package:shuttlebee/core/utils/logger.dart';
import 'package:shuttlebee/domain/repositories/auth_repository.dart';
import 'package:shuttlebee/presentation/providers/auth_state.dart';

/// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authRepository) : super(AuthState.initial()) {
    _checkAuthStatus();
  }

  final AuthRepository _authRepository;

  /// التحقق من حالة المصادقة عند البداية
  Future<void> _checkAuthStatus() async {
    final isAuthenticated = await _authRepository.isAuthenticated();

    if (isAuthenticated) {
      // جلب بيانات المستخدم
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) {
          AppLogger.warning('Failed to get user: ${failure.message}');
          state = AuthState.unauthenticated();
        },
        (user) {
          state = AuthState.authenticated(user);
        },
      );
    } else {
      state = AuthState.unauthenticated();
    }
  }

  /// تسجيل الدخول
  Future<void> login({
    required String url,
    required String database,
    required String username,
    required String password,
  }) async {
    state = AuthState.loading();

    final result = await _authRepository.login(
      url: url,
      database: database,
      username: username,
      password: password,
    );

    await result.fold(
      (failure) {
        AppLogger.error('Login failed', failure.message);
        state = AuthState.error(failure.message);
      },
      (auth) async {
        // التحقق من أن التوكنات محفوظة
        final isAuth = await _authRepository.isAuthenticated();
        AppLogger.info('After login - isAuthenticated: $isAuth');
        
        if (!isAuth) {
          AppLogger.error('Tokens not saved after login!');
          state = AuthState.error('فشل حفظ التوكنات');
          return;
        }
        
        // جلب بيانات المستخدم بعد تسجيل الدخول
        final userResult = await _authRepository.getCurrentUser();
        userResult.fold(
          (failure) {
            AppLogger.error('Failed to get user after login', failure.message);
            state = AuthState.error(failure.message);
          },
        (user) {
          AppLogger.info('Login successful: ${user.name}, role: ${user.role}');
          print('🎯 [AuthNotifier] User role: ${user.role}');
          print('🎯 [AuthNotifier] User shuttle_role: ${user.shuttleRole}');
          print('🎯 [AuthNotifier] User groups: ${user.groups.take(3).toList()}');
          
          // تحديث الحالة كمصادق عليه
          state = AuthState.authenticated(user);
          AppLogger.info(
            'AuthState updated - isAuthenticated: ${state.isAuthenticated}, '
            'user: ${user.name}, role: ${user.role}',
          );
        },
        );
      },
    );
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    state = AuthState.loading();

    final result = await _authRepository.logout();

    result.fold(
      (failure) {
        AppLogger.error('Logout failed', failure.message);
        // حتى لو فشل، نعتبر المستخدم غير مصادق
        state = AuthState.unauthenticated();
      },
      (_) {
        AppLogger.info('Logout successful');
        state = AuthState.unauthenticated();
      },
    );
  }

  /// تحديث بيانات المستخدم
  Future<void> refreshUser() async {
    final result = await _authRepository.getCurrentUser();

    result.fold(
      (failure) {
        AppLogger.error('Failed to refresh user', failure.message);
      },
      (user) {
        if (state.isAuthenticated) {
          state = AuthState.authenticated(user);
        }
      },
    );
  }
}

/// Auth State Provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
