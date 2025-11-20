import 'package:equatable/equatable.dart';

/// كيان المصادقة (Auth Entity)
class AuthEntity extends Equatable {
  const AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  /// تاريخ انتهاء الصلاحية
  DateTime get expiryDate =>
      DateTime.now().add(Duration(seconds: expiresIn));

  /// هل التوكن منتهي الصلاحية
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        tokenType,
        expiresIn,
      ];
}
