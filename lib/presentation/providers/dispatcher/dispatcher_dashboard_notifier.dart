import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/di/injection.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/domain/repositories/trip_repository.dart';
import 'package:shuttlebee/presentation/providers/dispatcher/dispatcher_dashboard_state.dart';

/// Dispatcher Dashboard Notifier
class DispatcherDashboardNotifier
    extends StateNotifier<DispatcherDashboardState> {
  DispatcherDashboardNotifier(
    this._tripRepository,
  ) : super(const DispatcherDashboardState());

  final TripRepository _tripRepository;

  /// Load dashboard statistics
  Future<void> loadDashboardStats() async {
    state = DispatcherDashboardState.loading();

    try {
      // Get today's date range
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Load trips for today
      final tripsResult = await _tripRepository.getTrips(
        dateFrom: todayStart,
        dateTo: todayEnd,
      );

      tripsResult.fold(
        (failure) {
          state = DispatcherDashboardState.error(failure.message);
        },
        (trips) {
          final ongoing = trips.where((t) => t.isOngoing).length;
          final completed =
              trips.where((t) => t.state == TripState.done).length;
          final cancelled =
              trips.where((t) => t.state == TripState.cancelled).length;

          state = state.copyWith(
            totalTripsToday: trips.length,
            ongoingTrips: ongoing,
            completedTrips: completed,
            cancelledTrips: cancelled,
            isLoading: false,
            error: null,
          );
        },
      );

      // TODO: Load vehicle and driver statistics
      // This requires Vehicle and Driver repositories

    } catch (e) {
      state = DispatcherDashboardState.error(e.toString());
    }
  }

  /// Refresh dashboard
  Future<void> refresh() async {
    await loadDashboardStats();
  }
}

/// Provider for Dispatcher Dashboard Notifier
final dispatcherDashboardNotifierProvider = StateNotifierProvider<
    DispatcherDashboardNotifier, DispatcherDashboardState>((ref) {
  return DispatcherDashboardNotifier(
    ref.watch(tripRepositoryProvider),
  );
});
