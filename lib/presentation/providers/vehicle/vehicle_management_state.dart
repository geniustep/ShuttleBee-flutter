import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/domain/entities/vehicle_entity.dart';

part 'vehicle_management_state.freezed.dart';

/// Vehicle Management State - حالة إدارة المركبات
@freezed
class VehicleManagementState with _$VehicleManagementState {
  const factory VehicleManagementState({
    @Default([]) List<VehicleEntity> vehicles,
    @Default([]) List<VehicleEntity> filteredVehicles,
    VehicleEntity? selectedVehicle,
    @Default(false) bool isLoading,
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,
    @Default(false) bool isDeleting,
    String? error,
  }) = _VehicleManagementState;

  const VehicleManagementState._();

  /// Create loading state
  factory VehicleManagementState.loading() {
    return const VehicleManagementState(isLoading: true);
  }

  /// Create error state
  factory VehicleManagementState.error(String message) {
    return VehicleManagementState(error: message, isLoading: false);
  }

  /// Check if any operation is in progress
  bool get isOperating => isCreating || isUpdating || isDeleting;
}

