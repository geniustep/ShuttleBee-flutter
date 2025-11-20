import 'package:freezed_annotation/freezed_annotation.dart';

part 'manager_analytics_state.freezed.dart';

/// Manager Analytics State - حالة تحليلات المدير
@freezed
class ManagerAnalyticsState with _$ManagerAnalyticsState {
  const factory ManagerAnalyticsState({
    // Overview Statistics
    @Default(0) int totalTripsThisMonth,
    @Default(0) int completedTripsThisMonth,
    @Default(0) int cancelledTripsThisMonth,
    @Default(0.0) double completionRate,
    @Default(0.0) double cancellationRate,

    // Performance Metrics
    @Default(0.0) double averageDelayMinutes,
    @Default(0.0) double onTimePercentage,
    @Default(0) int totalPassengersTransported,
    @Default(0.0) double averageOccupancyRate,

    // Resource Statistics
    @Default(0) int totalVehicles,
    @Default(0) int activeVehicles,
    @Default(0) int totalDrivers,
    @Default(0) int activeDrivers,
    @Default(0.0) double vehicleUtilizationRate,
    @Default(0.0) double driverUtilizationRate,

    // Cost Metrics
    @Default(0.0) double totalDistanceKm,
    @Default(0.0) double averageDistancePerTrip,
    @Default(0.0) double estimatedFuelCost,

    // Trend Data (last 7 days)
    @Default([]) List<DailyTripStat> dailyStats,

    @Default(false) bool isLoading,
    String? error,
  }) = _ManagerAnalyticsState;

  const ManagerAnalyticsState._();

  /// Create loading state
  factory ManagerAnalyticsState.loading() {
    return const ManagerAnalyticsState(isLoading: true);
  }

  /// Create error state
  factory ManagerAnalyticsState.error(String message) {
    return ManagerAnalyticsState(error: message, isLoading: false);
  }
}

/// Daily Trip Statistics
@freezed
class DailyTripStat with _$DailyTripStat {
  const factory DailyTripStat({
    required DateTime date,
    required int totalTrips,
    required int completedTrips,
    required int cancelledTrips,
  }) = _DailyTripStat;
}
