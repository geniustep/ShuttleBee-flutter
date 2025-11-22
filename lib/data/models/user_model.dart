import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/core/config/app_config.dart';
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
    // API قد يعيد user ككائن منفصل أو مباشرة
    final userData = json['user'] as Map<String, dynamic>? ?? json;
    
    return UserModel(
      // API يعيد id كـ UUID string، نحتاج لتحويله أو استخدام odoo_user_id
      id: (userData['odoo_user_id'] as int?) ?? 
          (userData['id'] is int ? userData['id'] as int : 0),
      name: (userData['name'] as String?) ??
          (userData['full_name'] as String?) ??
          (userData['username'] as String?) ??
          '',
      email: userData['email'] as String? ?? '',
      role: _parseRole(userData),
      phone: userData['phone'] as String?,
      avatar: userData['image_url'] as String?,
      partnerId: userData['partner_id'] as int?,
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
    // في وضع التطوير، يمكن فرض دور معين من خلال DEBUG_ROLE_OVERRIDE
    if (AppConfig.isDebugMode && AppConfig.debugRoleOverride != null) {
      try {
        return UserRole.fromString(AppConfig.debugRoleOverride!);
      } catch (e) {
        // إذا كان الدور غير صحيح، نتابع بالطريقة العادية
      }
    }

    // BridgeCore API يعيد role مباشرة كـ string
    final roleString = json['role'] as String?;
    if (roleString != null) {
      try {
        // محاولة تحويل role string إلى UserRole
        // API قد يعيد: "admin", "manager", "driver", "dispatcher", "passenger"
        final roleLower = roleString.toLowerCase();
        
        // معالجة "admin" كـ manager
        if (roleLower == 'admin' || roleLower == 'manager') {
          return UserRole.manager;
        }
        
        // محاولة استخدام fromString
        return UserRole.fromString(roleLower);
      } catch (e) {
        // إذا فشل التحويل، نتابع بالطريقة القديمة
      }
    }

    // الطريقة القديمة للتوافق مع API القديم
    if (json['is_driver'] == true) return UserRole.driver;
    if (json['is_manager'] == true) return UserRole.manager;
    if (json['is_dispatcher'] == true) return UserRole.dispatcher;
    
    // في وضع التطوير، إذا لم يكن هناك دور محدد، نستخدم dispatcher كافتراضي
    if (AppConfig.isDebugMode) {
      return UserRole.dispatcher;
    }
    
    return UserRole.passenger;
  }
}
