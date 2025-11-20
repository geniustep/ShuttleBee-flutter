import 'package:shuttlebee/domain/entities/auth_entity.dart';

/// Auth model (manual, no code generation)
class AuthModel {
  const AuthModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 0,
    this.systemId,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String? systemId;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: (json['token_type'] as String?) ?? 'Bearer',
      expiresIn: (json['expires_in'] as int?) ?? 0,
      systemId: json['system_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        if (systemId != null) 'system_id': systemId,
      };

  /// Convert to domain entity
  AuthEntity toEntity() {
    return AuthEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      systemId: systemId,
    );
  }
}
