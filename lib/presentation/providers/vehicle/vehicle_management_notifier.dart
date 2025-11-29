import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/di/injection.dart';
import 'package:shuttlebee/domain/entities/vehicle_entity.dart';
import 'package:shuttlebee/domain/repositories/vehicle_repository.dart';
import 'package:shuttlebee/presentation/providers/vehicle/vehicle_management_state.dart';

/// Vehicle Management Notifier
class VehicleManagementNotifier
    extends StateNotifier<VehicleManagementState> {
  VehicleManagementNotifier(
    this._vehicleRepository,
  ) : super(const VehicleManagementState());

  final VehicleRepository _vehicleRepository;

  /// Load vehicles
  Future<void> loadVehicles() async {
    state = VehicleManagementState.loading();

    final result = await _vehicleRepository.getVehicles();

    result.fold(
      (failure) {
        state = VehicleManagementState.error(failure.message);
      },
      (vehicles) {
        state = state.copyWith(
          vehicles: vehicles,
          filteredVehicles: vehicles,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  /// Search vehicles
  void searchVehicles(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredVehicles: state.vehicles);
      return;
    }

    final filtered = state.vehicles
        .where((vehicle) =>
            vehicle.name.toLowerCase().contains(query.toLowerCase()) ||
            (vehicle.licensePlate?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();

    state = state.copyWith(filteredVehicles: filtered);
  }

  /// Create vehicle
  Future<bool> createVehicle({
    required String name,
    required int seatCapacity,
    String? licensePlate,
    int? driverId,
  }) async {
    state = state.copyWith(isCreating: true, error: null);

    final result = await _vehicleRepository.createVehicle(
      name: name,
      seatCapacity: seatCapacity,
      licensePlate: licensePlate,
      driverId: driverId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: failure.message,
        );
        return false;
      },
      (vehicle) {
        final updatedVehicles = [...state.vehicles, vehicle];
        state = state.copyWith(
          vehicles: updatedVehicles,
          filteredVehicles: updatedVehicles,
          isCreating: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Update vehicle
  Future<bool> updateVehicle({
    required int id,
    String? name,
    int? seatCapacity,
    String? licensePlate,
    int? driverId,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);

    final result = await _vehicleRepository.updateVehicle(
      id: id,
      name: name,
      seatCapacity: seatCapacity,
      licensePlate: licensePlate,
      driverId: driverId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return false;
      },
      (updatedVehicle) {
        final updatedVehicles = state.vehicles.map((vehicle) {
          return vehicle.id == id ? updatedVehicle : vehicle;
        }).toList();

        state = state.copyWith(
          vehicles: updatedVehicles,
          filteredVehicles: updatedVehicles,
          isUpdating: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Delete vehicle
  Future<bool> deleteVehicle(int id) async {
    state = state.copyWith(isDeleting: true, error: null);

    final result = await _vehicleRepository.deleteVehicle(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        final updatedVehicles =
            state.vehicles.where((vehicle) => vehicle.id != id).toList();

        state = state.copyWith(
          vehicles: updatedVehicles,
          filteredVehicles: updatedVehicles,
          isDeleting: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Select vehicle
  void selectVehicle(VehicleEntity vehicle) {
    state = state.copyWith(selectedVehicle: vehicle);
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(selectedVehicle: null);
  }

  /// Refresh vehicles
  Future<void> refresh() async {
    await loadVehicles();
  }
}

/// Provider for Vehicle Management Notifier
final vehicleManagementNotifierProvider =
    StateNotifierProvider<VehicleManagementNotifier, VehicleManagementState>(
  (ref) {
    return VehicleManagementNotifier(
      ref.watch(vehicleRepositoryProvider),
    );
  },
);


