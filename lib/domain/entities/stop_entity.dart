import 'package:equatable/equatable.dart';
import 'package:shuttlebee/core/enums/enums.dart';

/// كيان المحطة (Stop Entity)
class StopEntity extends Equatable {
  const StopEntity({
    required this.id,
    required this.name,
    required this.stopType,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.usageCount = 0,
  });

  final int id;
  final String name;
  final StopType stopType;
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final int usageCount;

  /// هل المحطة تدعم الاستقبال
  bool get supportsPickup => stopType.supportsPickup;

  /// هل المحطة تدعم التوصيل
  bool get supportsDropoff => stopType.supportsDropoff;

  @override
  List<Object?> get props => [
        id,
        name,
        stopType,
        latitude,
        longitude,
        address,
        city,
        usageCount,
      ];
}
