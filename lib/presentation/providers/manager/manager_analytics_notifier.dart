import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/di/injection.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';
import 'package:shuttlebee/domain/repositories/trip_repository.dart';
import 'package:shuttlebee/presentation/providers/manager/manager_analytics_state.dart';

/// Manager Analytics Notifier
class ManagerAnalyticsNotifier extends StateNotifier<ManagerAnalyticsState> {
  ManagerAnalyticsNotifier(
    this._tripRepository,
  ) : super(const ManagerAnalyticsState());

  final TripRepository _tripRepository;

  ManagerAnalyticsState _buildAnalyticsState(
    List<TripEntity> trips, {
    required DateTime referenceDate,
  }) {
    // Calculate statistics
    final completed =
        trips.where((t) => t.state == TripState.done).length;
    final cancelled =
        trips.where((t) => t.state == TripState.cancelled).length;
    final completionRate = trips.isEmpty ? 0.0 : (completed / trips.length) * 100;
    final cancellationRate =
        trips.isEmpty ? 0.0 : (cancelled / trips.length) * 100;

    // Calculate performance metrics
    final tripsWithDelay = trips.where((t) {
      if (t.actualStartTime != null && t.plannedStartTime != null) {
        return t.actualStartTime!.isAfter(t.plannedStartTime!);
      }
      return false;
    }).toList();

    var totalDelay = 0.0;
    for (final trip in tripsWithDelay) {
      final delay = trip.actualStartTime!
          .difference(trip.plannedStartTime!)
          .inMinutes
          .toDouble();
      totalDelay += delay;
    }

    final averageDelay =
        tripsWithDelay.isEmpty ? 0.0 : totalDelay / tripsWithDelay.length;

    final onTimeTrips = trips.where((t) {
      if (t.actualStartTime != null && t.plannedStartTime != null) {
        final diff =
            t.actualStartTime!.difference(t.plannedStartTime!).inMinutes.abs();
        // Within 5 minutes is considered on-time
        return diff <= 5;
      }
      return false;
    }).length;

    final onTimePercentage = trips.isEmpty ? 0.0 : (onTimeTrips / trips.length) * 100;

    // Calculate passenger statistics
    final totalPassengers = trips.fold<int>(0, (sum, trip) => sum + trip.boardedCount);

    final totalCapacity =
        trips.fold<int>(0, (sum, trip) => sum + trip.totalPassengers);

    final occupancyRate =
        totalCapacity == 0 ? 0.0 : (totalPassengers / totalCapacity) * 100;

    // Calculate distance
    // Distance is not available on TripEntity right now, so keep at zero
    const totalDistance = 0.0;

    final avgDistance = trips.isEmpty ? 0.0 : totalDistance / trips.length;

    // Calculate daily stats for last 7 days using reference date
    final last7Days = List.generate(
      7,
      (i) => DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
      ).subtract(Duration(days: 6 - i)),
    );

    final dailyStats = last7Days.map((date) {
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayTrips = trips.where((trip) {
        return trip.date.isAfter(dayStart) && trip.date.isBefore(dayEnd);
      }).toList();

      return DailyTripStat(
        date: dayStart,
        totalTrips: dayTrips.length,
        completedTrips:
            dayTrips.where((t) => t.state == TripState.done).length,
        cancelledTrips:
            dayTrips.where((t) => t.state == TripState.cancelled).length,
      );
    }).toList();

    return ManagerAnalyticsState(
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
  }

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
        dateFrom: monthStart,
        dateTo: monthEnd,
      );

      tripsResult.fold(
        (failure) {
          state = ManagerAnalyticsState.error(failure.message);
        },
        (trips) {
          state = _buildAnalyticsState(
            trips,
            referenceDate: now,
          );
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
      dateFrom: startDate,
      dateTo: endDate,
    );

    tripsResult.fold(
      (failure) {
        state = ManagerAnalyticsState.error(failure.message);
      },
      (trips) {
        state = _buildAnalyticsState(
          trips,
          referenceDate: endDate,
        );
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
