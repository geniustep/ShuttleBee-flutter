# 🚀 BridgeCore Flutter v0.2.0 Integration Guide

## 📋 نظرة عامة

تم تحديث `bridgecore_flutter` إلى **Version 0.2.0** مع ميزات جديدة رائعة!

---

## 🆕 الميزات الجديدة في v0.2.0

### 1. `/me` Endpoint المحسّن
```dart
// الحصول على معلومات المستخدم الكاملة
final userInfo = await BridgeCore.instance.auth.me();

print('User: ${userInfo.user.name}');
print('Email: ${userInfo.user.email}');
print('Tenant: ${userInfo.tenant.name}');
print('Odoo Database: ${userInfo.odooDatabase}');
print('Odoo Version: ${userInfo.odooVersion}');
```

### 2. نظام الصلاحيات الشامل
```dart
// التحقق من الصلاحيات
if (userInfo.user.hasPermission('fleet.vehicle', 'read')) {
  // يمكن قراءة المركبات
}

if (userInfo.user.canCreate('shuttle.trip')) {
  // يمكن إنشاء رحلات
}

if (userInfo.user.canUpdate('res.partner')) {
  // يمكن تحديث الشركاء
}

if (userInfo.user.canDelete('fleet.vehicle')) {
  // يمكن حذف المركبات
}
```

### 3. دعم Multi-Company
```dart
// الحصول على الشركات المتاحة
final companies = userInfo.user.allowedCompanyIds;
print('Available companies: $companies');

// الشركة الحالية
final currentCompany = userInfo.user.companyId;
print('Current company: $currentCompany');
```

### 4. Custom Fields Support
```dart
// الوصول إلى Custom Fields
final customFields = userInfo.user.customFields;
print('Custom fields: $customFields');

// مثال: shuttle_role
final shuttleRole = customFields['shuttle_role'];
```

### 5. Caching الذكي
```dart
// الـ /me response يتم cache تلقائياً
// يمكن التحكم في الـ cache:

// تحديث الـ cache
await BridgeCore.instance.auth.me(forceRefresh: true);

// مسح الـ cache
await BridgeCore.instance.clearCache();
```

---

## 🔧 التكامل مع ShuttleBee

### 1. تحديث UserModel

```dart
// lib/data/models/user_model.dart
import 'package:bridgecore_flutter/bridgecore_flutter.dart';

factory UserModel.fromTenantUser(TenantUser tenantUser) {
  return UserModel(
    id: tenantUser.id,
    name: tenantUser.name,
    email: tenantUser.email,
    role: _parseRole(tenantUser),
    phone: tenantUser.phone,
    avatar: tenantUser.image,
    partnerId: tenantUser.partnerId,
    customFields: tenantUser.customFields,
  );
}

static UserRole _parseRole(TenantUser user) {
  // استخدام shuttle_role من custom fields
  final shuttleRole = user.customFields['shuttle_role'];
  if (shuttleRole != null) {
    try {
      return UserRole.fromString(shuttleRole);
    } catch (e) {
      // fallback
    }
  }
  
  // استخدام groups
  if (user.hasGroup('fleet_manager')) return UserRole.manager;
  if (user.hasGroup('fleet_driver')) return UserRole.driver;
  if (user.hasGroup('fleet_dispatcher')) return UserRole.dispatcher;
  
  return UserRole.passenger;
}
```

### 2. تحديث AuthService

```dart
// lib/core/services/bridgecore_service.dart

/// الحصول على معلومات المستخدم الحالي
Future<Map<String, dynamic>> getCurrentUser() async {
  try {
    final userInfo = await BridgeCore.instance.auth.me();
    
    return {
      'user': {
        'id': userInfo.user.id,
        'name': userInfo.user.name,
        'email': userInfo.user.email,
        'phone': userInfo.user.phone,
        'image': userInfo.user.image,
        'partner_id': userInfo.user.partnerId,
        'company_id': userInfo.user.companyId,
        'allowed_company_ids': userInfo.user.allowedCompanyIds,
        'groups': userInfo.user.groups,
        'permissions': userInfo.user.permissions,
        'custom_fields': userInfo.user.customFields,
      },
      'tenant': {
        'id': userInfo.tenant.id,
        'name': userInfo.tenant.name,
        'subdomain': userInfo.tenant.subdomain,
      },
      'odoo_database': userInfo.odooDatabase,
      'odoo_version': userInfo.odooVersion,
    };
  } catch (e) {
    throw Exception(e.toString());
  }
}
```

### 3. إضافة Permission Checks

```dart
// lib/core/utils/permission_helper.dart

class PermissionHelper {
  /// التحقق من صلاحية
  static bool hasPermission(
    UserEntity user,
    String model,
    String operation,
  ) {
    // TODO: استخدام permissions من TenantUser
    return true; // placeholder
  }
  
  /// التحقق من إمكانية الإنشاء
  static bool canCreate(UserEntity user, String model) {
    return hasPermission(user, model, 'create');
  }
  
  /// التحقق من إمكانية القراءة
  static bool canRead(UserEntity user, String model) {
    return hasPermission(user, model, 'read');
  }
  
  /// التحقق من إمكانية التحديث
  static bool canUpdate(UserEntity user, String model) {
    return hasPermission(user, model, 'update');
  }
  
  /// التحقق من إمكانية الحذف
  static bool canDelete(UserEntity user, String model) {
    return hasPermission(user, model, 'delete');
  }
}
```

### 4. إضافة Profile Screen

```dart
// lib/presentation/screens/profile/profile_screen.dart

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('لم يتم تسجيل الدخول')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            _buildUserInfo(user),
            
            const SizedBox(height: 24),
            
            // Permissions
            _buildPermissions(user),
            
            const SizedBox(height: 24),
            
            // Companies
            _buildCompanies(user),
            
            const SizedBox(height: 24),
            
            // Custom Fields
            _buildCustomFields(user),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserInfo(UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معلومات المستخدم', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            _buildInfoRow('الاسم', user.name),
            _buildInfoRow('البريد الإلكتروني', user.email),
            if (user.phone != null) _buildInfoRow('الهاتف', user.phone!),
            _buildInfoRow('الدور', user.role.arabicLabel),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPermissions(UserEntity user) {
    // TODO: عرض الصلاحيات من user.permissions
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الصلاحيات', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            Text('يمكنك إنشاء رحلات: ${PermissionHelper.canCreate(user, "shuttle.trip") ? "✅" : "❌"}'),
            Text('يمكنك تعديل المركبات: ${PermissionHelper.canUpdate(user, "fleet.vehicle") ? "✅" : "❌"}'),
            Text('يمكنك حذف الشركاء: ${PermissionHelper.canDelete(user, "res.partner") ? "✅" : "❌"}'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCompanies(UserEntity user) {
    // TODO: عرض الشركات من user.allowedCompanyIds
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الشركات', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            Text('الشركة الحالية: TODO'),
            Text('الشركات المتاحة: TODO'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCustomFields(UserEntity user) {
    if (user.customFields.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('حقول مخصصة', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            ...user.customFields.entries.map((entry) {
              return _buildInfoRow(entry.key, entry.value.toString());
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎯 الخطوات التالية

### 1. تحديث Models
- [ ] إضافة permissions إلى UserEntity
- [ ] إضافة allowedCompanyIds إلى UserEntity
- [ ] إضافة groups إلى UserEntity

### 2. تحديث Services
- [ ] استخدام me() بدلاً من getCurrentUser() القديم
- [ ] إضافة permission checks في جميع العمليات
- [ ] إضافة company switching support

### 3. تحديث UI
- [ ] إضافة Profile Screen
- [ ] عرض الصلاحيات في UI
- [ ] إخفاء/إظهار features بناءً على الصلاحيات
- [ ] إضافة company selector

### 4. Testing
- [ ] اختبار /me endpoint
- [ ] اختبار permission checks
- [ ] اختبار multi-company support
- [ ] اختبار custom fields

---

## 📚 Resources

- [BridgeCore Flutter v0.2.0 Release](https://github.com/geniustep/bridgecore_flutter)
- [ME_ENDPOINT.md](https://github.com/geniustep/bridgecore_flutter/blob/main/ME_ENDPOINT.md)
- [NEW_FEATURES.md](https://github.com/geniustep/bridgecore_flutter/blob/main/NEW_FEATURES.md)

---

## 🎉 الخلاصة

**BridgeCore Flutter v0.2.0** يوفر:
- ✅ /me endpoint محسّن
- ✅ نظام صلاحيات شامل
- ✅ Multi-company support
- ✅ Custom fields support
- ✅ Caching ذكي

هذه الميزات ستحسّن ShuttleBee بشكل كبير! 🚀

