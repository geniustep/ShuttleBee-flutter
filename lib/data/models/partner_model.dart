import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/domain/entities/partner_entity.dart';

part 'partner_model.freezed.dart';
part 'partner_model.g.dart';

/// نموذج الشريك - راكب أو سائق (Partner Model)
@freezed
class PartnerModel with _$PartnerModel {
  const PartnerModel._();

  const factory PartnerModel({
    required int id,
    required String name,
    String? email,
    String? phone,
    String? mobile,
    @Default(false) bool isShuttlePassenger,
    @Default(false) bool isDriver,
    int? defaultPickupStopId,
    String? defaultPickupStopName,
    int? defaultDropoffStopId,
    String? defaultDropoffStopName,
    double? shuttleLatitude,
    double? shuttleLongitude,
  }) = _PartnerModel;

  /// من JSON
  factory PartnerModel.fromJson(Map<String, dynamic> json) =>
      _$PartnerModelFromJson(json);

  /// من BridgeCore API Response
  factory PartnerModel.fromBridgeCoreResponse(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      mobile: json['mobile'] as String?,
      isShuttlePassenger: json['is_shuttle_passenger'] as bool? ?? false,
      isDriver: json['is_driver'] as bool? ?? false,
      defaultPickupStopId: _parseId(json['default_pickup_stop_id']),
      defaultPickupStopName: _parseName(json['default_pickup_stop_id']),
      defaultDropoffStopId: _parseId(json['default_dropoff_stop_id']),
      defaultDropoffStopName: _parseName(json['default_dropoff_stop_id']),
      shuttleLatitude: (json['shuttle_latitude'] as num?)?.toDouble(),
      shuttleLongitude: (json['shuttle_longitude'] as num?)?.toDouble(),
    );
  }

  /// تحويل إلى Entity
  PartnerEntity toEntity() {
    return PartnerEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      mobile: mobile,
      isShuttlePassenger: isShuttlePassenger,
      isDriver: isDriver,
      defaultPickupStopId: defaultPickupStopId,
      defaultPickupStopName: defaultPickupStopName,
      defaultDropoffStopId: defaultDropoffStopId,
      defaultDropoffStopName: defaultDropoffStopName,
      shuttleLatitude: shuttleLatitude,
      shuttleLongitude: shuttleLongitude,
    );
  }

  /// Helper methods
  static int? _parseId(dynamic value) {
    if (value == null || value == false) return null;
    if (value is int) return value;
    if (value is List && value.isNotEmpty) return value[0] as int;
    return null;
  }

  static String? _parseName(dynamic value) {
    if (value == null || value == false) return null;
    if (value is String) return value;
    if (value is List && value.length > 1) return value[1] as String;
    return null;
  }
}
