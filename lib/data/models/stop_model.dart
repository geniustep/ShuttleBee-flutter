import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/domain/entities/stop_entity.dart';

part 'stop_model.freezed.dart';
part 'stop_model.g.dart';

/// نموذج المحطة (Stop Model)
@freezed
class StopModel with _$StopModel {
  const StopModel._();

  const factory StopModel({
    required int id,
    required String name,
    required StopType stopType,
    required double latitude,
    required double longitude,
    String? address,
    String? city,
    @Default(0) int usageCount,
  }) = _StopModel;

  /// من JSON
  factory StopModel.fromJson(Map<String, dynamic> json) =>
      _$StopModelFromJson(json);

  /// من BridgeCore API Response
  factory StopModel.fromBridgeCoreResponse(Map<String, dynamic> json) {
    return StopModel(
      id: json['id'] as int,
      name: json['name'] as String,
      stopType: StopType.fromString(json['stop_type'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      usageCount: json['usage_count'] as int? ?? 0,
    );
  }

  /// تحويل إلى Entity
  StopEntity toEntity() {
    return StopEntity(
      id: id,
      name: name,
      stopType: stopType,
      latitude: latitude,
      longitude: longitude,
      address: address,
      city: city,
      usageCount: usageCount,
    );
  }
}
