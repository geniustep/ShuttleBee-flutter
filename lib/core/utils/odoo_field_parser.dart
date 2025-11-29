/// Utility class للتعامل مع Odoo field formats
class OdooFieldParser {
  OdooFieldParser._();

  /// Parse any Odoo field value
  static T? parseField<T>(dynamic value) {
    if (value == null || value == false) return null;

    // Handle many2one [id, name]
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

    // Handle DateTime
    if (T == DateTime) {
      if (value is String) {
        return DateTime.tryParse(value) as T?;
      }
    }

    // Direct cast
    try {
      return value as T?;
    } catch (e) {
      return null;
    }
  }

  /// Parse many2one field to get ID
  static int? parseId(dynamic value) {
    if (value == null || value == false) return null;
    if (value is int) return value;
    if (value is List && value.isNotEmpty) return value[0] as int?;
    return null;
  }

  /// Parse many2one field to get name
  static String? parseName(dynamic value) {
    if (value == null || value == false) return null;
    if (value is String) return value;
    if (value is List && value.length > 1) return value[1] as String?;
    return null;
  }

  /// Parse many2many field to get list of IDs
  static List<int> parseIds(dynamic value) {
    if (value == null || value == false) return [];
    if (value is List) {
      return value.whereType<int>().toList();
    }
    return [];
  }

  /// Parse date field
  static DateTime? parseDate(dynamic value) {
    if (value == null || value == false) return null;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Parse float field
  static double? parseFloat(dynamic value) {
    if (value == null || value == false) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse integer field
  static int? parseInt(dynamic value) {
    if (value == null || value == false) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Parse boolean field
  static bool parseBool(dynamic value) {
    if (value == null || value == false) return false;
    return true;
  }

  /// Extract custom fields from JSON (fields starting with x_)
  static Map<String, dynamic> extractCustomFields(
    Map<String, dynamic> json, {
    String prefix = 'x_',
  }) {
    return Map.fromEntries(
      json.entries.where((entry) => entry.key.startsWith(prefix)),
    );
  }

  /// Extract standard fields (non-custom)
  static Map<String, dynamic> extractStandardFields(
    Map<String, dynamic> json, {
    String customPrefix = 'x_',
  }) {
    return Map.fromEntries(
      json.entries.where((entry) => !entry.key.startsWith(customPrefix)),
    );
  }

  /// Merge custom fields into a map
  static Map<String, dynamic> mergeCustomFields(
    Map<String, dynamic> standardFields,
    Map<String, dynamic> customFields,
  ) {
    return {...standardFields, ...customFields};
  }

  /// Parse list of records (One2many/Many2many with full details)
  /// 
  /// Example: [{'id': 1, 'name': 'CPR'}, {'id': 2, 'name': 'First Aid'}]
  static List<Map<String, dynamic>> parseRecordList(dynamic value) {
    if (value == null || value == false) return [];
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  /// Parse list of any type
  /// 
  /// Example: ['Arabic', 'English', 'French']
  static List<T> parseList<T>(dynamic value) {
    if (value == null || value == false) return [];
    if (value is List) {
      return value.whereType<T>().toList();
    }
    return [];
  }

  /// Parse One2many field with full records
  /// Checks if it's list of IDs or list of records
  static List<Map<String, dynamic>> parseOne2manyRecords(dynamic value) {
    if (value == null || value == false) return [];
    if (value is List) {
      if (value.isEmpty) return [];
      
      // Check if it's list of records (not just IDs)
      if (value.first is Map) {
        return value.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  /// Parse Selection field (returns the key)
  static String? parseSelection(dynamic value) {
    if (value == null || value == false) return null;
    if (value is String) return value;
    if (value is List && value.isNotEmpty) return value[0] as String?;
    return null;
  }
}

