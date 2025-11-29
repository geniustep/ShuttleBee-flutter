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
    @Default(null) int? companyId,
    @Default([]) List<int> allowedCompanyIds,
    @Default([]) List<String> groups,
    @Default({}) Map<String, Map<String, bool>> permissions,
    @Default({}) Map<String, dynamic> customFields,
  }) = _UserModel;

  /// من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// ✅ من BridgeCore API Response (متوافق مع /me endpoint الحقيقي)
  factory UserModel.fromBridgeCoreResponse(Map<String, dynamic> json) {
    print('📥 [UserModel.fromBridgeCoreResponse] Parsing API response...');

    // API يعيد user ككائن منفصل
    final userData = json['user'] as Map<String, dynamic>? ?? json;

    // استخراج odoo_fields_data (مثل shuttle_role)
    final odooFieldsData = json['odoo_fields_data'] as Map<String, dynamic>?;
    final customFields = odooFieldsData ?? {};
    print('📥 [UserModel.fromBridgeCoreResponse] customFields: $customFields');

    // استخراج groups من المستوى الأعلى
    final groups =
        (json['groups'] as List?)?.map((e) => e.toString()).toList() ?? [];
    print(
        '📥 [UserModel.fromBridgeCoreResponse] groups count: ${groups.length}');

    // استخراج company info
    final companyIds =
        (json['company_ids'] as List?)?.map((e) => e as int).toList() ?? [];
    final currentCompanyId = json['current_company_id'] as int?;

    // استخراج partner_id من المستوى الأعلى
    final partnerId = json['partner_id'] as int?;

    final model = UserModel(
      // استخدام odoo_user_id من user object
      id: (userData['odoo_user_id'] as int?) ?? 0,
      name: (userData['full_name'] as String?) ??
          (userData['name'] as String?) ??
          '',
      email: userData['email'] as String? ?? '',
      role: _parseRole(json), // تمرير الـ json الكامل لاستخراج shuttle_role
      phone: userData['phone'] as String?,
      avatar: userData['image_url'] as String?,
      partnerId: partnerId,
      companyId: currentCompanyId,
      allowedCompanyIds: companyIds,
      groups: groups,
      permissions: _parsePermissions(json['permissions']),
      customFields: customFields,
    );

    print(
        '✅ [UserModel.fromBridgeCoreResponse] Created user: ${model.name}, role: ${model.role}');
    return model;
  }

  /// ✅ من TenantUser (BridgeCore v0.2.0)
  /// Note: نستخدم toJson() لأن الـ API قد يكون مختلفاً
  factory UserModel.fromTenantUser(dynamic tenantUser) {
    // Convert to JSON first for compatibility
    final json =
        tenantUser is Map ? tenantUser : (tenantUser as dynamic).toJson();
    return UserModel.fromBridgeCoreResponse({'user': json});
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
      companyId: companyId,
      allowedCompanyIds: allowedCompanyIds,
      groups: groups,
      permissions: permissions,
      customFields: customFields,
    );
  }

  /// Parse permissions من API response
  static Map<String, Map<String, bool>> _parsePermissions(
      dynamic permissionsData) {
    if (permissionsData == null) return {};
    if (permissionsData is! Map) return {};

    final result = <String, Map<String, bool>>{};
    permissionsData.forEach((key, value) {
      if (value is Map) {
        result[key.toString()] = {
          'create': value['create'] == true,
          'read': value['read'] == true,
          'update': value['update'] == true,
          'delete': value['delete'] == true,
        };
      }
    });
    return result;
  }

  /// ✅ تحديد دور المستخدم من البيانات (يستخدم shuttle_role من odoo_fields_data)
  static UserRole _parseRole(Map<String, dynamic> json) {
    print('🔍 [UserModel._parseRole] Starting role parsing...');
    print('🔍 [UserModel._parseRole] JSON keys: ${json.keys.toList()}');

    // في وضع التطوير، يمكن فرض دور معين من خلال DEBUG_ROLE_OVERRIDE
    if (AppConfig.isDebugMode && AppConfig.debugRoleOverride != null) {
      print(
          '🔧 [UserModel._parseRole] DEBUG_ROLE_OVERRIDE: ${AppConfig.debugRoleOverride}');
      try {
        final role = UserRole.fromString(AppConfig.debugRoleOverride!);
        print('✅ [UserModel._parseRole] Using DEBUG_ROLE_OVERRIDE: $role');
        return role;
      } catch (e) {
        print(
            '⚠️ [UserModel._parseRole] Invalid DEBUG_ROLE_OVERRIDE, continuing...');
      }
    }

    // ✅ أولاً: محاولة استخدام shuttle_role من odoo_fields_data
    final odooFieldsData = json['odoo_fields_data'] as Map<String, dynamic>?;
    print('🔍 [UserModel._parseRole] odoo_fields_data: $odooFieldsData');

    if (odooFieldsData != null) {
      final shuttleRole = odooFieldsData['shuttle_role'] as String?;
      print('🔍 [UserModel._parseRole] shuttle_role: $shuttleRole');

      if (shuttleRole != null) {
        try {
          final role = UserRole.fromString(shuttleRole.toLowerCase());
          print('✅ [UserModel._parseRole] Using shuttle_role: $role');
          return role;
        } catch (e) {
          print('⚠️ [UserModel._parseRole] Failed to parse shuttle_role: $e');
        }
      }
    }

    // ثانياً: محاولة استخدام groups
    final groups =
        (json['groups'] as List?)?.map((e) => e.toString()).toList() ?? [];
    print(
        '🔍 [UserModel._parseRole] groups (${groups.length}): ${groups.take(3).toList()}...');

    if (groups.contains('shuttlebee.group_shuttle_manager')) {
      print('✅ [UserModel._parseRole] Using groups: manager');
      return UserRole.manager;
    }
    if (groups.contains('shuttlebee.group_shuttle_driver')) {
      print('✅ [UserModel._parseRole] Using groups: driver');
      return UserRole.driver;
    }
    if (groups.contains('shuttlebee.group_shuttle_dispatcher')) {
      print('✅ [UserModel._parseRole] Using groups: dispatcher');
      return UserRole.dispatcher;
    }

    // ثالثاً: استخدام role من user object
    final userData = json['user'] as Map<String, dynamic>?;
    if (userData != null) {
      final roleString = userData['role'] as String?;
      print('🔍 [UserModel._parseRole] user.role: $roleString');

      if (roleString != null && roleString.toLowerCase() == 'admin') {
        print('✅ [UserModel._parseRole] Using user.role: manager');
        return UserRole.manager;
      }
    }

    // رابعاً: استخدام اسم المستخدم كـ fallback (chauffeur = driver)
    final userName = userData?['full_name'] as String?;
    if (userName != null) {
      final userNameLower = userName.toLowerCase();
      print('🔍 [UserModel._parseRole] Checking username: $userName');

      if (userNameLower.contains('chauffeur') ||
          userNameLower.contains('driver')) {
        print('✅ [UserModel._parseRole] Using username pattern: driver');
        return UserRole.driver;
      }
      if (userNameLower.contains('dispatcher') ||
          userNameLower.contains('مرسل')) {
        print('✅ [UserModel._parseRole] Using username pattern: dispatcher');
        return UserRole.dispatcher;
      }
      if (userNameLower.contains('manager') || userNameLower.contains('مدير')) {
        print('✅ [UserModel._parseRole] Using username pattern: manager');
        return UserRole.manager;
      }
    }

    // افتراضي
    print('⚠️ [UserModel._parseRole] No role found, defaulting to passenger');
    return UserRole.passenger;
  }
}
