import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/di/injection.dart';
import 'package:shuttlebee/domain/repositories/trip_repository.dart';
import 'package:shuttlebee/presentation/providers/passenger/passenger_trips_state.dart';

/// Passenger Trips Notifier
class PassengerTripsNotifier extends StateNotifier<PassengerTripsState> {
  PassengerTripsNotifier(
    this._tripRepository,
  ) : super(const PassengerTripsState());

  final TripRepository _tripRepository;

  /// Load passenger trips
  Future<void> loadMyTrips() async {
    state = PassengerTripsState.loading();

    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Get trips for passenger
      // In production, this should filter by passenger ID
      final tripsResult = await _tripRepository.getTrips();

      tripsResult.fold(
        (failure) {
          state = PassengerTripsState.error(failure.message);
        },
        (allTrips) {
          // Filter today's trips
          final today = allTrips
              .where((trip) =>
                  trip.date.isAfter(todayStart) && trip.date.isBefore(todayEnd))
              .toList();

          // Filter upcoming trips
          final upcoming = allTrips
              .where((trip) => trip.date.isAfter(todayEnd) && !trip.isDone)
              .toList();

          // Filter completed trips
          final completed =
              allTrips.where((trip) => trip.isDone).take(10).toList();

          // Find active trip
          final active =
              today.firstWhere((trip) => trip.isOngoing, orElse: () => today.first);

          state = state.copyWith(
            todayTrips: today,
            upcomingTrips: upcoming,
            completedTrips: completed,
            activeTrip: active.isOngoing ? active : null,
            isLoading: false,
            error: null,
          );
        },
      );
    } catch (e) {
      state = PassengerTripsState.error(e.toString());
    }
  }

  /// Refresh trips
  Future<void> refresh() async {
    await loadMyTrips();
  }

  /// Select active trip
  void setActiveTrip(trip) {
    state = state.copyWith(activeTrip: trip);
  }
}

/// Provider for Passenger Trips Notifier
final passengerTripsNotifierProvider =
    StateNotifierProvider<PassengerTripsNotifier, PassengerTripsState>((ref) {
  return PassengerTripsNotifier(
    ref.watch(tripRepositoryProvider),
  );
});
