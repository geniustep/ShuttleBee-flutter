import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/domain/entities/auth_entity.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

/// نموذج المصادقة (Auth Model)
@freezed
class AuthModel with _$AuthModel {
  const AuthModel._();

  const factory AuthModel({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
  }) = _AuthModel;

  /// من JSON
  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);

  /// تحويل إلى Entity
  AuthEntity toEntity() {
    return AuthEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
    );
  }
}
