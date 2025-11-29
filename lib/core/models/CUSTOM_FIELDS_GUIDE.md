# دليل استخدام Custom Fields في ShuttleBee

## 📋 نظرة عامة

هذا النظام يسمح بإضافة custom fields من Odoo إلى أي model دون الحاجة لتعديل الكود الأساسي.

---

## 🚀 كيفية الاستخدام

### 1. إضافة Custom Fields لـ Model موجود

#### الخطوة 1: إضافة Mixin و customFields property

```dart
import 'package:shuttlebee/core/models/custom_fields_mixin.dart';
import 'package:shuttlebee/core/utils/odoo_field_parser.dart';

@freezed
class UserModel with _$UserModel, CustomFieldsMixin {
  const UserModel._();

  const factory UserModel({
    required int id,
    required String name,
    // ... باقي الحقول
    @Default({}) Map<String, dynamic> customFields, // إضافة هذا
  }) = _UserModel;
}
```

#### الخطوة 2: تحديث fromBridgeCoreResponse

```dart
factory UserModel.fromBridgeCoreResponse(Map<String, dynamic> json) {
  // Extract custom fields
  final customFields = OdooFieldParser.extractCustomFields(json);
  
  return UserModel(
    id: json['id'] as int,
    name: json['name'] as String,
    // ... باقي الحقول
    customFields: customFields, // إضافة هذا
  );
}
```

---

## 📖 أمثلة الاستخدام

### مثال 1: Custom Field بسيط (String)

```dart
// في Odoo: أضفنا x_badge_number (Char field)
final user = await userRepository.getCurrentUser();

// الوصول للـ custom field
final badgeNumber = user.getCustomField<String>('x_badge_number');
print('Badge Number: $badgeNumber');

// التحقق من وجود الحقل
if (user.hasCustomField('x_badge_number')) {
  print('User has badge number');
}
```

### مثال 2: Many2one Field

```dart
// في Odoo: أضفنا x_department_id (Many2one to hr.department)
final user = await userRepository.getCurrentUser();

// الحصول على ID
final departmentId = user.getCustomFieldId('x_department_id');
print('Department ID: $departmentId');

// الحصول على Name
final departmentName = user.getCustomFieldName('x_department_id');
print('Department: $departmentName');

// أو استخدام getCustomField
final deptId = user.getCustomField<int>('x_department_id');
final deptName = user.getCustomField<String>('x_department_id');
```

### مثال 3: Many2many Field

```dart
// في Odoo: أضفنا x_skill_ids (Many2many to hr.skill)
final user = await userRepository.getCurrentUser();

// الحصول على قائمة IDs
final skillIds = user.getCustomFieldIds('x_skill_ids');
print('Skills: $skillIds'); // [1, 5, 8]
```

### مثال 4: Boolean Field

```dart
// في Odoo: أضفنا x_is_certified (Boolean)
final user = await userRepository.getCurrentUser();

final isCertified = user.getCustomField<bool>('x_is_certified') ?? false;
if (isCertified) {
  print('User is certified');
}
```

### مثال 5: Integer/Float Fields

```dart
// في Odoo: أضفنا x_years_experience (Integer)
final user = await userRepository.getCurrentUser();

final experience = user.getCustomField<int>('x_years_experience') ?? 0;
print('Experience: $experience years');

// Float field
final rating = user.getCustomField<double>('x_rating') ?? 0.0;
print('Rating: $rating');
```

### مثال 6: Date Field

```dart
// في Odoo: أضفنا x_hire_date (Date)
final user = await userRepository.getCurrentUser();

// استخدام OdooFieldParser
final hireDate = OdooFieldParser.parseDate(
  user.customFields['x_hire_date']
);
if (hireDate != null) {
  print('Hired on: ${hireDate.toString()}');
}
```

### مثال 7: الحصول على جميع Custom Fields

```dart
final user = await userRepository.getCurrentUser();

// جميع custom fields
final allCustomFields = user.customFields;
print('All custom fields: $allCustomFields');

// فقط الحقول التي تبدأ بـ x_
final xFields = user.getCustomFieldsByPrefix('x_');
print('X fields: $xFields');
```

---

## 🎯 استخدام في UI

### مثال: عرض Badge Number في Profile Screen

```dart
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    return Column(
      children: [
        Text('Name: ${user.name}'),
        Text('Email: ${user.email}'),
        
        // Custom field
        if (user.hasCustomField('x_badge_number'))
          Text('Badge: ${user.getCustomField<String>('x_badge_number')}'),
        
        // Many2one field
        if (user.hasCustomField('x_department_id'))
          Text('Department: ${user.getCustomFieldName('x_department_id')}'),
      ],
    );
  }
}
```

### مثال: Form مع Custom Field

```dart
class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _badgeController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    final user = widget.user;
    
    // Load custom field value
    _badgeController.text = 
      user.getCustomField<String>('x_badge_number') ?? '';
  }
  
  Future<void> _save() async {
    // Update with custom field
    await userRepository.updateUser(
      id: user.id,
      data: {
        'name': _nameController.text,
        'x_badge_number': _badgeController.text, // Custom field
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _badgeController,
          decoration: InputDecoration(labelText: 'Badge Number'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text('Save'),
        ),
      ],
    );
  }
}
```

---

## 🔧 OdooFieldParser Utilities

### Parse Any Field Type

```dart
// Parse any type
final value = OdooFieldParser.parseField<String>(json['x_field']);

// Parse specific types
final id = OdooFieldParser.parseId(json['x_many2one_field']);
final name = OdooFieldParser.parseName(json['x_many2one_field']);
final ids = OdooFieldParser.parseIds(json['x_many2many_field']);
final date = OdooFieldParser.parseDate(json['x_date_field']);
final amount = OdooFieldParser.parseFloat(json['x_float_field']);
final count = OdooFieldParser.parseInt(json['x_integer_field']);
final flag = OdooFieldParser.parseBool(json['x_boolean_field']);
```

### Extract Custom Fields

```dart
// Extract all custom fields (starting with x_)
final customFields = OdooFieldParser.extractCustomFields(json);

// Extract with custom prefix
final customFields = OdooFieldParser.extractCustomFields(
  json,
  prefix: 'custom_',
);

// Extract standard fields only
final standardFields = OdooFieldParser.extractStandardFields(json);
```

---

## 📝 أمثلة حسب نوع الـ Model

### UserModel - Custom Fields

```dart
// في Odoo أضفنا:
// - x_badge_number (Char)
// - x_department_id (Many2one to hr.department)
// - x_employee_code (Char)
// - x_is_certified (Boolean)

final user = await userRepository.getCurrentUser();

final badgeNumber = user.getCustomField<String>('x_badge_number');
final departmentId = user.getCustomFieldId('x_department_id');
final departmentName = user.getCustomFieldName('x_department_id');
final employeeCode = user.getCustomField<String>('x_employee_code');
final isCertified = user.getCustomField<bool>('x_is_certified') ?? false;
```

### VehicleModel - Custom Fields

```dart
// في Odoo أضفنا:
// - x_fuel_type (Selection: diesel, petrol, electric)
// - x_last_maintenance_date (Date)
// - x_insurance_expiry (Date)
// - x_gps_device_id (Char)

final vehicle = await vehicleRepository.getVehicleById(id);

final fuelType = vehicle.getCustomField<String>('x_fuel_type');
final lastMaintenance = OdooFieldParser.parseDate(
  vehicle.customFields['x_last_maintenance_date']
);
final insuranceExpiry = OdooFieldParser.parseDate(
  vehicle.customFields['x_insurance_expiry']
);
final gpsDeviceId = vehicle.getCustomField<String>('x_gps_device_id');
```

### TripModel - Custom Fields

```dart
// في Odoo أضفنا:
// - x_trip_category (Selection)
// - x_special_instructions (Text)
// - x_estimated_fuel_cost (Float)

final trip = await tripRepository.getTripById(id);

final category = trip.getCustomField<String>('x_trip_category');
final instructions = trip.getCustomField<String>('x_special_instructions');
final fuelCost = trip.getCustomField<double>('x_estimated_fuel_cost');
```

---

## ⚠️ ملاحظات مهمة

### 1. تسمية Custom Fields في Odoo
- يجب أن تبدأ بـ `x_` (مثل: `x_badge_number`)
- استخدم snake_case

### 2. أنواع البيانات
- **Char/Text**: `String`
- **Integer**: `int`
- **Float**: `double`
- **Boolean**: `bool`
- **Date/Datetime**: استخدم `OdooFieldParser.parseDate()`
- **Many2one**: استخدم `getCustomFieldId()` و `getCustomFieldName()`
- **Many2many**: استخدم `getCustomFieldIds()`

### 3. القيم الافتراضية
دائماً استخدم `??` للقيم الافتراضية:
```dart
final value = user.getCustomField<String>('x_field') ?? 'default';
```

### 4. التحقق من الوجود
تحقق من وجود الحقل قبل استخدامه:
```dart
if (user.hasCustomField('x_badge_number')) {
  // استخدم الحقل
}
```

---

## 🔄 تحديث Custom Fields

### في Repository

```dart
// في UserRepository
Future<Either<Failure, UserEntity>> updateUser({
  required int id,
  String? name,
  Map<String, dynamic>? customFields, // إضافة هذا
}) async {
  final data = <String, dynamic>{
    if (name != null) 'name': name,
    // Add custom fields
    if (customFields != null) ...customFields,
  };
  
  final result = await remoteDataSource.updateUser(id, data);
  return Right(result.toEntity());
}
```

### الاستخدام

```dart
await userRepository.updateUser(
  id: user.id,
  customFields: {
    'x_badge_number': '12345',
    'x_department_id': departmentId,
    'x_is_certified': true,
  },
);
```

---

## ✅ Checklist لإضافة Custom Field جديد

1. ✅ أضف الحقل في Odoo (يبدأ بـ `x_`)
2. ✅ تأكد أن Model يستخدم `CustomFieldsMixin`
3. ✅ تأكد أن `customFields` property موجود في Model
4. ✅ تأكد أن `fromBridgeCoreResponse` يستخرج custom fields
5. ✅ استخدم `getCustomField<T>()` للوصول للقيمة
6. ✅ استخدم `??` للقيم الافتراضية
7. ✅ اختبر في UI

---

## 🎓 أمثلة متقدمة

### مثال: Validation لـ Custom Field

```dart
String? validateBadgeNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Badge number is required';
  }
  
  final user = ref.read(currentUserProvider);
  final existingBadge = user.getCustomField<String>('x_badge_number');
  
  if (value == existingBadge) {
    return null; // No change
  }
  
  // Check format
  if (!RegExp(r'^\d{5}$').hasMatch(value)) {
    return 'Badge number must be 5 digits';
  }
  
  return null;
}
```

### مثال: Computed Property من Custom Field

```dart
extension UserModelExtension on UserModel {
  /// Check if user is senior (based on custom field)
  bool get isSenior {
    final experience = getCustomField<int>('x_years_experience') ?? 0;
    return experience >= 5;
  }
  
  /// Get full department info
  String get departmentInfo {
    if (!hasCustomField('x_department_id')) {
      return 'No department';
    }
    
    final deptName = getCustomFieldName('x_department_id');
    final deptId = getCustomFieldId('x_department_id');
    
    return '$deptName (#$deptId)';
  }
}
```

---

## 🚀 الخلاصة

هذا النظام يوفر:
- ✅ مرونة كاملة لإضافة custom fields
- ✅ Type-safe access
- ✅ سهولة الاستخدام
- ✅ لا حاجة لتعديل الكود الأساسي
- ✅ دعم جميع أنواع Odoo fields
- ✅ Documentation شامل

**الآن يمكنك إضافة أي custom field في Odoo واستخدامه مباشرة في التطبيق!** 🎉

