import 'package:equatable/equatable.dart';

/// Auth Entity
class AuthEntity extends Equatable {
  const AuthEntity({
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

  DateTime get expiryDate => DateTime.now().add(Duration(seconds: expiresIn));

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        tokenType,
        expiresIn,
        systemId,
      ];
}
