/// نوع الرحلة
enum TripType {
  pickup('pickup', 'استقبال', 'Pickup'),
  dropoff('dropoff', 'توصيل', 'Drop-off');

  const TripType(this.value, this.arabicLabel, this.englishLabel);

  final String value;
  final String arabicLabel;
  final String englishLabel;

  /// تحويل من String إلى Enum
  static TripType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pickup':
        return TripType.pickup;
      case 'dropoff':
        return TripType.dropoff;
      default:
        throw ArgumentError('Invalid TripType: $value');
    }
  }

  /// الحصول على التسمية حسب اللغة
  String getLabel(String languageCode) {
    return languageCode == 'ar' ? arabicLabel : englishLabel;
  }
}
