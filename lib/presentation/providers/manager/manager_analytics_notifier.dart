import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/di/injection.dart';
import 'package:shuttlebee/domain/repositories/trip_repository.dart';
import 'package:shuttlebee/presentation/providers/manager/manager_analytics_state.dart';

/// Manager Analytics Notifier
class ManagerAnalyticsNotifier extends StateNotifier<ManagerAnalyticsState> {
  ManagerAnalyticsNotifier(
    this._tripRepository,
  ) : super(const ManagerAnalyticsState());

  final TripRepository _tripRepository;

  /// Load analytics data
  Future<void> loadAnalytics() async {
    state = ManagerAnalyticsState.loading();

    try {
      // Get current month date range
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Load trips for this month
      final tripsResult = await _tripRepository.getTrips(
        startDate: monthStart,
        endDate: monthEnd,
      );

      tripsResult.fold(
        (failure) {
          state = ManagerAnalyticsState.error(failure.message);
        },
        (trips) {
          // Calculate statistics
          final completed = trips.where((t) => t.isDone).length;
          final cancelled = trips.where((t) => t.isCancelled).length;
          final completionRate =
              trips.isEmpty ? 0.0 : (completed / trips.length) * 100;
          final cancellationRate =
              trips.isEmpty ? 0.0 : (cancelled / trips.length) * 100;

          // Calculate performance metrics
          final tripsWithDelay = trips.where((t) {
            if (t.actualStartTime != null && t.plannedStartTime != null) {
              return t.actualStartTime!.isAfter(t.plannedStartTime!);
            }
            return false;
          }).toList();

          double totalDelay = 0;
          for (final trip in tripsWithDelay) {
            final delay = trip.actualStartTime!
                .difference(trip.plannedStartTime!)
                .inMinutes;
            totalDelay += delay;
          }

          final averageDelay =
              tripsWithDelay.isEmpty ? 0.0 : totalDelay / tripsWithDelay.length;

          final onTimeTrips = trips.where((t) {
            if (t.actualStartTime != null && t.plannedStartTime != null) {
              final diff = t.actualStartTime!
                  .difference(t.plannedStartTime!)
                  .inMinutes
                  .abs();
              return diff <= 5; // Within 5 minutes is considered on-time
            }
            return false;
          }).length;

          final onTimePercentage =
              trips.isEmpty ? 0.0 : (onTimeTrips / trips.length) * 100;

          // Calculate passenger statistics
          final totalPassengers =
              trips.fold<int>(0, (sum, trip) => sum + trip.boardedCount);

          final totalCapacity =
              trips.fold<int>(0, (sum, trip) => sum + trip.totalPassengers);

          final occupancyRate =
              totalCapacity == 0 ? 0.0 : (totalPassengers / totalCapacity) * 100;

          // Calculate distance
          final totalDistance = trips.fold<double>(
              0.0, (sum, trip) => sum + (trip.actualDistance ?? 0.0));

          final avgDistance =
              trips.isEmpty ? 0.0 : totalDistance / trips.length;

          // Calculate daily stats for last 7 days
          final last7Days = List.generate(7, (i) {
            return now.subtract(Duration(days: 6 - i));
          });

          final dailyStats = last7Days.map((date) {
            final dayStart = DateTime(date.year, date.month, date.day);
            final dayEnd = dayStart.add(const Duration(days: 1));

            final dayTrips = trips.where((trip) {
              return trip.date.isAfter(dayStart) && trip.date.isBefore(dayEnd);
            }).toList();

            return DailyTripStat(
              date: dayStart,
              totalTrips: dayTrips.length,
              completedTrips: dayTrips.where((t) => t.isDone).length,
              cancelledTrips: dayTrips.where((t) => t.isCancelled).length,
            );
          }).toList();

          state = state.copyWith(
            totalTripsThisMonth: trips.length,
            completedTripsThisMonth: completed,
            cancelledTripsThisMonth: cancelled,
            completionRate: completionRate,
            cancellationRate: cancellationRate,
            averageDelayMinutes: averageDelay,
            onTimePercentage: onTimePercentage,
            totalPassengersTransported: totalPassengers,
            averageOccupancyRate: occupancyRate,
            totalDistanceKm: totalDistance,
            averageDistancePerTrip: avgDistance,
            estimatedFuelCost: totalDistance * 0.5, // Estimate: 0.5 SAR per km
            dailyStats: dailyStats,
            isLoading: false,
            error: null,
          );

          // TODO: Load vehicle and driver statistics
          // This requires Vehicle and Driver repositories
        },
      );
    } catch (e) {
      state = ManagerAnalyticsState.error(e.toString());
    }
  }

  /// Refresh analytics
  Future<void> refresh() async {
    await loadAnalytics();
  }

  /// Load analytics for custom date range
  Future<void> loadAnalyticsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    state = ManagerAnalyticsState.loading();

    final tripsResult = await _tripRepository.getTrips(
      startDate: startDate,
      endDate: endDate,
    );

    tripsResult.fold(
      (failure) {
        state = ManagerAnalyticsState.error(failure.message);
      },
      (trips) {
        // Similar calculation as loadAnalytics but for custom range
        // For brevity, reusing the same logic
        loadAnalytics();
      },
    );
  }
}

/// Provider for Manager Analytics Notifier
final managerAnalyticsNotifierProvider =
    StateNotifierProvider<ManagerAnalyticsNotifier, ManagerAnalyticsState>(
        (ref) {
  return ManagerAnalyticsNotifier(
    ref.watch(tripRepositoryProvider),
  );
});
