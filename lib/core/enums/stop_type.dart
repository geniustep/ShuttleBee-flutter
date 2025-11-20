/// نوع المحطة
enum StopType {
  pickup('pickup', 'استقبال', 'Pickup'),
  dropoff('dropoff', 'توصيل', 'Drop-off'),
  both('both', 'كلاهما', 'Both');

  const StopType(this.value, this.arabicLabel, this.englishLabel);

  final String value;
  final String arabicLabel;
  final String englishLabel;

  /// تحويل من String إلى Enum
  static StopType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pickup':
        return StopType.pickup;
      case 'dropoff':
        return StopType.dropoff;
      case 'both':
        return StopType.both;
      default:
        throw ArgumentError('Invalid StopType: $value');
    }
  }

  /// الحصول على التسمية حسب اللغة
  String getLabel(String languageCode) {
    return languageCode == 'ar' ? arabicLabel : englishLabel;
  }

  /// هل المحطة تدعم الاستقبال
  bool get supportsPickup => this == StopType.pickup || this == StopType.both;

  /// هل المحطة تدعم التوصيل
  bool get supportsDropoff =>
      this == StopType.dropoff || this == StopType.both;
}
