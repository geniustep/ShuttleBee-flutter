/// Mixin للتعامل مع Custom Fields من Odoo
/// 
/// يسمح بإضافة custom fields لأي model دون الحاجة لتعديل الكود الأساسي
mixin CustomFieldsMixin {
  /// Custom fields من Odoo (يتم تخزينها كـ Map)
  Map<String, dynamic> get customFields;

  /// الحصول على قيمة custom field
  /// 
  /// Example:
  /// ```dart
  /// final badgeNumber = user.getCustomField<String>('x_badge_number');
  /// final department = user.getCustomField<String>('x_department');
  /// ```
  T? getCustomField<T>(String fieldName) {
    if (!customFields.containsKey(fieldName)) {
      return null;
    }

    final value = customFields[fieldName];

    // Handle Odoo's many2one format [id, name]
    if (value is List && value.isNotEmpty) {
      if (T == int) {
        return value[0] as T?;
      } else if (T == String) {
        return (value.length > 1 ? value[1] : value[0].toString()) as T?;
      }
    }

    // Handle boolean
    if (T == bool) {
      if (value == false || value == null) return false as T;
      return true as T;
    }

    // Direct cast for other types
    return value as T?;
  }

  /// الحصول على ID من many2one field
  int? getCustomFieldId(String fieldName) {
    final value = customFields[fieldName];
    if (value == null || value == false) return null;
    if (value is int) return value;
    if (value is List && value.isNotEmpty) return value[0] as int;
    return null;
  }

  /// الحصول على Name من many2one field
  String? getCustomFieldName(String fieldName) {
    final value = customFields[fieldName];
    if (value == null || value == false) return null;
    if (value is String) return value;
    if (value is List && value.length > 1) return value[1] as String;
    return null;
  }

  /// الحصول على قائمة IDs من many2many field
  List<int> getCustomFieldIds(String fieldName) {
    final value = customFields[fieldName];
    if (value == null || value == false) return [];
    if (value is List) {
      return value.whereType<int>().toList();
    }
    return [];
  }

  /// التحقق من وجود custom field
  bool hasCustomField(String fieldName) {
    return customFields.containsKey(fieldName);
  }

  /// الحصول على جميع custom fields التي تبدأ بـ prefix معين
  /// 
  /// Example:
  /// ```dart
  /// final xFields = user.getCustomFieldsByPrefix('x_');
  /// ```
  Map<String, dynamic> getCustomFieldsByPrefix(String prefix) {
    return Map.fromEntries(
      customFields.entries.where((entry) => entry.key.startsWith(prefix)),
    );
  }

  /// تحويل custom field إلى JSON
  Map<String, dynamic> customFieldsToJson() {
    return Map<String, dynamic>.from(customFields);
  }
}

