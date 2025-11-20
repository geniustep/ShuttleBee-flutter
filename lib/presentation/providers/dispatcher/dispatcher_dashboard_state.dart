import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispatcher_dashboard_state.freezed.dart';

/// Dispatcher Dashboard State - حالة لوحة تحكم المرسل
@freezed
class DispatcherDashboardState with _$DispatcherDashboardState {
  const factory DispatcherDashboardState({
    @Default(0) int totalTripsToday,
    @Default(0) int ongoingTrips,
    @Default(0) int completedTrips,
    @Default(0) int cancelledTrips,
    @Default(0) int totalVehicles,
    @Default(0) int activeVehicles,
    @Default(0) int totalDrivers,
    @Default(0) int activeDrivers,
    @Default(0) int totalPassengers,
    @Default(false) bool isLoading,
    String? error,
  }) = _DispatcherDashboardState;

  const DispatcherDashboardState._();

  /// Create loading state
  factory DispatcherDashboardState.loading() {
    return const DispatcherDashboardState(isLoading: true);
  }

  /// Create error state
  factory DispatcherDashboardState.error(String message) {
    return DispatcherDashboardState(error: message, isLoading: false);
  }
}
