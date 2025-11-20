import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/di/injection.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';
import 'package:shuttlebee/domain/repositories/trip_repository.dart';
import 'package:shuttlebee/presentation/providers/dispatcher/trip_management_state.dart';

/// Trip Management Notifier
class TripManagementNotifier extends StateNotifier<TripManagementState> {
  TripManagementNotifier(
    this._tripRepository,
  ) : super(const TripManagementState());

  final TripRepository _tripRepository;

  /// Load trips
  Future<void> loadTrips({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    state = TripManagementState.loading();

    final result = await _tripRepository.getTrips(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    result.fold(
      (failure) {
        state = TripManagementState.error(failure.message);
      },
      (trips) {
        state = state.copyWith(
          trips: trips,
          filteredTrips: _applyFilters(trips),
          isLoading: false,
          error: null,
        );
      },
    );
  }

  /// Apply filters to trips
  List<TripEntity> _applyFilters(List<TripEntity> trips) {
    var filtered = trips;

    // Filter by status
    if (state.filterStatus != 'all') {
      filtered = filtered.where((trip) {
        switch (state.filterStatus) {
          case 'planned':
            return trip.state == TripState.planned;
          case 'ongoing':
            return trip.state == TripState.ongoing;
          case 'done':
            return trip.state == TripState.done;
          case 'cancelled':
            return trip.state == TripState.cancelled;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by date range
    if (state.filterStartDate != null) {
      filtered = filtered
          .where((trip) => trip.date.isAfter(state.filterStartDate!))
          .toList();
    }

    if (state.filterEndDate != null) {
      filtered = filtered
          .where((trip) => trip.date.isBefore(state.filterEndDate!))
          .toList();
    }

    return filtered;
  }

  /// Set filter status
  void setFilterStatus(String status) {
    state = state.copyWith(filterStatus: status);
    state = state.copyWith(filteredTrips: _applyFilters(state.trips));
  }

  /// Set filter date range
  void setFilterDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      filterStartDate: startDate,
      filterEndDate: endDate,
    );
    state = state.copyWith(filteredTrips: _applyFilters(state.trips));
  }

  /// Select trip
  void selectTrip(TripEntity trip) {
    state = state.copyWith(selectedTrip: trip);
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(selectedTrip: null);
  }

  /// Create new trip
  Future<bool> createTrip({
    required String name,
    required DateTime date,
    required TripType tripType,
    required int groupId,
    int? vehicleId,
    int? driverId,
    DateTime? plannedStartTime,
    DateTime? plannedArrivalTime,
  }) async {
    state = state.copyWith(isCreating: true, error: null);

    final result = await _tripRepository.createTrip(
      name: name,
      date: date,
      tripType: tripType,
      groupId: groupId,
      vehicleId: vehicleId,
      driverId: driverId,
      plannedStartTime: plannedStartTime,
      plannedArrivalTime: plannedArrivalTime,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: failure.message,
        );
        return false;
      },
      (trip) {
        // Add new trip to list
        final updatedTrips = [...state.trips, trip];
        state = state.copyWith(
          trips: updatedTrips,
          filteredTrips: _applyFilters(updatedTrips),
          isCreating: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Update trip
  Future<bool> updateTrip({
    required int tripId,
    String? name,
    DateTime? date,
    TripType? tripType,
    int? groupId,
    int? vehicleId,
    int? driverId,
    DateTime? plannedStartTime,
    DateTime? plannedArrivalTime,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);

    final result = await _tripRepository.updateTrip(
      id: tripId,
      name: name,
      date: date,
      tripType: tripType,
      groupId: groupId,
      vehicleId: vehicleId,
      driverId: driverId,
      plannedStartTime: plannedStartTime,
      plannedArrivalTime: plannedArrivalTime,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return false;
      },
      (updatedTrip) {
        // Update trip in list
        final updatedTrips = state.trips.map((trip) {
          return trip.id == tripId ? updatedTrip : trip;
        }).toList();

        state = state.copyWith(
          trips: updatedTrips,
          filteredTrips: _applyFilters(updatedTrips),
          selectedTrip:
              state.selectedTrip?.id == tripId ? updatedTrip : state.selectedTrip,
          isUpdating: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Cancel trip
  Future<bool> cancelTrip(int tripId) async {
    state = state.copyWith(isUpdating: true, error: null);

    final result = await _tripRepository.cancelTrip(tripId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return false;
      },
      (updatedTrip) {
        // Update trip in list
        final updatedTrips = state.trips.map((trip) {
          return trip.id == tripId ? updatedTrip : trip;
        }).toList();

        state = state.copyWith(
          trips: updatedTrips,
          filteredTrips: _applyFilters(updatedTrips),
          selectedTrip:
              state.selectedTrip?.id == tripId ? updatedTrip : state.selectedTrip,
          isUpdating: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Delete trip
  Future<bool> deleteTrip(int tripId) async {
    state = state.copyWith(isDeleting: true, error: null);

    final result = await _tripRepository.deleteTrip(tripId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        // Remove trip from list
        final updatedTrips = state.trips.where((trip) => trip.id != tripId).toList();

        state = state.copyWith(
          trips: updatedTrips,
          filteredTrips: _applyFilters(updatedTrips),
          selectedTrip: state.selectedTrip?.id == tripId ? null : state.selectedTrip,
          isDeleting: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Refresh trips
  Future<void> refresh() async {
    await loadTrips(
      dateFrom: state.filterStartDate,
      dateTo: state.filterEndDate,
    );
  }
}

/// Provider for Trip Management Notifier
final tripManagementNotifierProvider =
    StateNotifierProvider<TripManagementNotifier, TripManagementState>((ref) {
  return TripManagementNotifier(
    ref.watch(tripRepositoryProvider),
  );
});
