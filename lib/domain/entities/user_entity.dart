import 'package:equatable/equatable.dart';
import 'package:shuttlebee/core/enums/enums.dart';

/// كيان المستخدم (User Entity)
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatar,
    this.partnerId,
  });

  final int id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? avatar;
  final int? partnerId;

  /// هل المستخدم لديه صلاحية إدارية
  bool get isAdmin => role.isAdmin;

  /// هل المستخدم سائق
  bool get isDriver => role.isDriver;

  /// هل المستخدم راكب
  bool get isPassenger => role.isPassenger;

  /// هل المستخدم مدير
  bool get isManager => role.isManager;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        phone,
        avatar,
        partnerId,
      ];
}
