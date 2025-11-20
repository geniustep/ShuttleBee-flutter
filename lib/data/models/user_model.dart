import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// نموذج المستخدم (User Model)
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required int id,
    required String name,
    required String email,
    required UserRole role,
    String? phone,
    String? avatar,
    int? partnerId,
  }) = _UserModel;

  /// من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// من BridgeCore API Response
  factory UserModel.fromBridgeCoreResponse(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: (json['name'] as String?) ??
          (json['full_name'] as String?) ??
          (json['username'] as String?) ??
          '',
      email: json['email'] as String? ?? '',
      role: _parseRole(json),
      phone: json['phone'] as String?,
      avatar: json['image_url'] as String?,
      partnerId: json['partner_id'] as int?,
    );
  }

  /// تحويل إلى Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: role,
      phone: phone,
      avatar: avatar,
      partnerId: partnerId,
    );
  }

  /// تحديد دور المستخدم من البيانات
  static UserRole _parseRole(Map<String, dynamic> json) {
    // يمكن تعديل هذا حسب البنية الفعلية لـ API
    if (json['is_driver'] == true) return UserRole.driver;
    if (json['is_manager'] == true) return UserRole.manager;
    if (json['is_dispatcher'] == true) return UserRole.dispatcher;
    return UserRole.passenger;
  }
}
