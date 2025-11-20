import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';

part 'passenger_trips_state.freezed.dart';

/// Passenger Trips State - حالة رحلات الراكب
@freezed
class PassengerTripsState with _$PassengerTripsState {
  const factory PassengerTripsState({
    @Default([]) List<TripEntity> upcomingTrips,
    @Default([]) List<TripEntity> todayTrips,
    @Default([]) List<TripEntity> completedTrips,
    TripEntity? activeTrip,
    @Default(false) bool isLoading,
    String? error,
  }) = _PassengerTripsState;

  const PassengerTripsState._();

  /// Create loading state
  factory PassengerTripsState.loading() {
    return const PassengerTripsState(isLoading: true);
  }

  /// Create error state
  factory PassengerTripsState.error(String message) {
    return PassengerTripsState(error: message, isLoading: false);
  }

  /// Check if passenger has active trip
  bool get hasActiveTrip => activeTrip != null;
}
