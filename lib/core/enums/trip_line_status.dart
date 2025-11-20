import 'package:flutter/material.dart';

/// حالة الراكب في الرحلة
enum TripLineStatus {
  notStarted('not_started', 'لم تبدأ', 'Not Started', Color(0xFF9E9E9E)),
  absent('absent', 'غائب', 'Absent', Color(0xFFF44336)),
  boarded('boarded', 'صعد', 'Boarded', Color(0xFF2196F3)),
  dropped('dropped', 'نزل', 'Dropped', Color(0xFF4CAF50));

  const TripLineStatus(
    this.value,
    this.arabicLabel,
    this.englishLabel,
    this.color,
  );

  final String value;
  final String arabicLabel;
  final String englishLabel;
  final Color color;

  /// تحويل من String إلى Enum
  static TripLineStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'not_started':
        return TripLineStatus.notStarted;
      case 'absent':
        return TripLineStatus.absent;
      case 'boarded':
        return TripLineStatus.boarded;
      case 'dropped':
        return TripLineStatus.dropped;
      default:
        throw ArgumentError('Invalid TripLineStatus: $value');
    }
  }

  /// الحصول على التسمية حسب اللغة
  String getLabel(String languageCode) {
    return languageCode == 'ar' ? arabicLabel : englishLabel;
  }

  /// هل الراكب على متن الحافلة
  bool get isOnBoard => this == TripLineStatus.boarded;

  /// هل الراكب نزل
  bool get isDropped => this == TripLineStatus.dropped;

  /// هل الراكب غائب
  bool get isAbsent => this == TripLineStatus.absent;

  /// هل يمكن وضع علامة صعد
  bool get canMarkBoarded => this == TripLineStatus.notStarted;

  /// هل يمكن وضع علامة غائب
  bool get canMarkAbsent => this == TripLineStatus.notStarted;

  /// هل يمكن وضع علامة نزل
  bool get canMarkDropped => this == TripLineStatus.boarded;
}
