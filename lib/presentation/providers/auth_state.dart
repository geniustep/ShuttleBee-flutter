import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

/// حالة المصادقة
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isAuthenticated,
    @Default(false) bool isLoading,
    UserEntity? user,
    String? error,
  }) = _AuthState;

  factory AuthState.initial() => const AuthState();

  factory AuthState.authenticated(UserEntity user) => AuthState(
        isAuthenticated: true,
        isLoading: false,
        user: user,
      );

  factory AuthState.unauthenticated() => const AuthState(
        isAuthenticated: false,
        isLoading: false,
      );

  factory AuthState.loading() => const AuthState(
        isLoading: true,
      );

  factory AuthState.error(String message) => AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: message,
      );
}
