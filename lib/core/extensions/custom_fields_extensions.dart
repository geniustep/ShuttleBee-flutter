import 'package:shuttlebee/core/utils/odoo_field_parser.dart';

/// Extension methods لإضافة Custom Fields functionality لأي model
/// 
/// استخدم هذا Extension لأي model يحتوي على customFields property
extension CustomFieldsExtension on dynamic {
  /// الحصول على قيمة custom field
  /// 
  /// Example:
  /// ```dart
  /// final vehicle = await vehicleRepository.getVehicleById(id);
  /// final fuelType = vehicle.getCustomField<String>('x_fuel_type');
  /// ```
  T? getCustomField<T>(String fieldName) {
    // Check if object has customFields property
    try {
      final customFields = (this as dynamic).customFields as Map<String, dynamic>?;
      if (customFields == null) return null;
      return OdooFieldParser.parseField<T>(customFields[fieldName]);
    } catch (e) {
      return null;
    }
  }

  /// الحصول على ID من many2one field
  int? getCustomFieldId(String fieldName) {
    try {
      final customFields = (this as dynamic).customFields as Map<String, dynamic>?;
      if (customFields == null) return null;
      return OdooFieldParser.parseId(customFields[fieldName]);
    } catch (e) {
      return null;
    }
  }

  /// الحصول على Name من many2one field
  String? getCustomFieldName(String fieldName) {
    try {
      final customFields = (this as dynamic).customFields as Map<String, dynamic>?;
      if (customFields == null) return null;
      return OdooFieldParser.parseName(customFields[fieldName]);
    } catch (e) {
      return null;
    }
  }

  /// الحصول على قائمة IDs من many2many field
  List<int> getCustomFieldIds(String fieldName) {
    try {
      final customFields = (this as dynamic).customFields as Map<String, dynamic>?;
      if (customFields == null) return [];
      return OdooFieldParser.parseIds(customFields[fieldName]);
    } catch (e) {
      return [];
    }
  }

  /// التحقق من وجود custom field
  bool hasCustomField(String fieldName) {
    try {
      final customFields = (this as dynamic).customFields as Map<String, dynamic>?;
      return customFields?.containsKey(fieldName) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على جميع custom fields التي تبدأ بـ prefix معين
  Map<String, dynamic> getCustomFieldsByPrefix(String prefix) {
    try {
      final customFields = (this as dynamic).customFields as Map<String, dynamic>?;
      if (customFields == null) return {};
      return Map.fromEntries(
        customFields.entries.where((entry) => entry.key.startsWith(prefix)),
      );
    } catch (e) {
      return {};
    }
  }

  /// الحصول على جميع custom fields
  Map<String, dynamic> getAllCustomFields() {
    try {
      final customFields = (this as dynamic).customFields as Map<String, dynamic>?;
      return customFields ?? {};
    } catch (e) {
      return {};
    }
  }
}

/// Helper function لإضافة custom fields لأي Freezed model
/// 
/// استخدم هذا في fromBridgeCoreResponse:
/// ```dart
/// factory VehicleModel.fromBridgeCoreResponse(Map<String, dynamic> json) {
///   return VehicleModel(
///     id: json['id'] as int,
///     name: json['name'] as String,
///     customFields: extractCustomFields(json),
///   );
/// }
/// ```
Map<String, dynamic> extractCustomFields(
  Map<String, dynamic> json, {
  String prefix = 'x_',
}) {
  return OdooFieldParser.extractCustomFields(json, prefix: prefix);
}

