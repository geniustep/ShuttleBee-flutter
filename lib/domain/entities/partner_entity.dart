import 'package:equatable/equatable.dart';

/// كيان الشريك - راكب أو سائق (Partner Entity)
class PartnerEntity extends Equatable {
  const PartnerEntity({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.mobile,
    this.isShuttlePassenger = false,
    this.isDriver = false,
    this.defaultPickupStopId,
    this.defaultPickupStopName,
    this.defaultDropoffStopId,
    this.defaultDropoffStopName,
    this.shuttleLatitude,
    this.shuttleLongitude,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? mobile;
  final bool isShuttlePassenger;
  final bool isDriver;
  final int? defaultPickupStopId;
  final String? defaultPickupStopName;
  final int? defaultDropoffStopId;
  final String? defaultDropoffStopName;
  final double? shuttleLatitude;
  final double? shuttleLongitude;

  /// رقم الهاتف المفضل
  String? get preferredPhone => mobile ?? phone;

  /// هل لديه محطة استقبال افتراضية
  bool get hasDefaultPickupStop => defaultPickupStopId != null;

  /// هل لديه محطة توصيل افتراضية
  bool get hasDefaultDropoffStop => defaultDropoffStopId != null;

  /// هل لديه موقع محدد
  bool get hasLocation => shuttleLatitude != null && shuttleLongitude != null;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        mobile,
        isShuttlePassenger,
        isDriver,
        defaultPickupStopId,
        defaultPickupStopName,
        defaultDropoffStopId,
        defaultDropoffStopName,
        shuttleLatitude,
        shuttleLongitude,
      ];
}
