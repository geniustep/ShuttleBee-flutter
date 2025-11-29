import 'package:shuttlebee/core/models/custom_fields_mixin.dart';
import 'package:shuttlebee/core/utils/odoo_field_parser.dart';

/// Base class لجميع Odoo models
/// يوفر functionality أساسي للتعامل مع custom fields
abstract class BaseOdooModel with CustomFieldsMixin {
  BaseOdooModel({
    required this.id,
    Map<String, dynamic>? customFields,
  }) : _customFields = customFields ?? {};

  final int id;
  final Map<String, dynamic> _customFields;

  @override
  Map<String, dynamic> get customFields => _customFields;

  /// Parse custom fields from BridgeCore response
  static Map<String, dynamic> parseCustomFieldsFromResponse(
    Map<String, dynamic> json, {
    String prefix = 'x_',
  }) {
    return OdooFieldParser.extractCustomFields(json, prefix: prefix);
  }

  /// Convert model to JSON including custom fields
  Map<String, dynamic> toJsonWithCustomFields(Map<String, dynamic> baseJson) {
    return OdooFieldParser.mergeCustomFields(baseJson, customFields);
  }
}

