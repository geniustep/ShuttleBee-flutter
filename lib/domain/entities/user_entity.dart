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
    this.companyId,
    this.allowedCompanyIds = const [],
    this.groups = const [],
    this.permissions = const {},
    this.customFields = const {},
  });

  final int id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? avatar;
  final int? partnerId;
  
  // ✅ New fields from BridgeCore v0.2.0
  final int? companyId;
  final List<int> allowedCompanyIds;
  final List<String> groups;
  final Map<String, Map<String, bool>> permissions; // model -> {create, read, update, delete}
  final Map<String, dynamic> customFields;

  /// هل المستخدم لديه صلاحية إدارية
  bool get isAdmin => role.isAdmin;

  /// هل المستخدم سائق
  bool get isDriver => role.isDriver;

  /// هل المستخدم راكب
  bool get isPassenger => role.isPassenger;

  /// هل المستخدم مدير
  bool get isManager => role.isManager;

  // ========== Permission Methods ==========

  /// التحقق من صلاحية معينة
  bool hasPermission(String model, String operation) {
    final modelPermissions = permissions[model];
    if (modelPermissions == null) return false;
    return modelPermissions[operation] ?? false;
  }

  /// هل يمكن إنشاء سجل في model معين
  bool canCreate(String model) => hasPermission(model, 'create');

  /// هل يمكن قراءة سجل من model معين
  bool canRead(String model) => hasPermission(model, 'read');

  /// هل يمكن تحديث سجل في model معين
  bool canUpdate(String model) => hasPermission(model, 'update');

  /// هل يمكن حذف سجل من model معين
  bool canDelete(String model) => hasPermission(model, 'delete');

  // ========== Group Methods ==========

  /// التحقق من انتماء المستخدم لمجموعة معينة
  bool hasGroup(String groupName) => groups.contains(groupName);

  /// هل المستخدم مدير أسطول
  bool get isFleetManager => hasGroup('fleet_manager');

  /// هل المستخدم سائق أسطول
  bool get isFleetDriver => hasGroup('fleet_driver');

  /// هل المستخدم مرسل
  bool get isFleetDispatcher => hasGroup('fleet_dispatcher');

  // ========== Company Methods ==========

  /// هل المستخدم لديه وصول لعدة شركات
  bool get hasMultipleCompanies => allowedCompanyIds.length > 1;

  /// هل يمكن الوصول لشركة معينة
  bool canAccessCompany(int companyId) => allowedCompanyIds.contains(companyId);

  // ========== Custom Fields Methods ==========

  /// الحصول على قيمة custom field
  T? getCustomField<T>(String fieldName) {
    final value = customFields[fieldName];
    if (value is T) return value;
    return null;
  }

  /// الحصول على shuttle_role من custom fields
  String? get shuttleRole => getCustomField<String>('shuttle_role');

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        phone,
        avatar,
        partnerId,
        companyId,
        allowedCompanyIds,
        groups,
        permissions,
        customFields,
      ];
}
