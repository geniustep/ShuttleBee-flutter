import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';
import 'package:shuttlebee/domain/entities/trip_line_entity.dart';

part 'active_trip_state.freezed.dart';

/// حالة الرحلة النشطة
@freezed
class ActiveTripState with _$ActiveTripState {
  const factory ActiveTripState({
    TripEntity? trip,
    @Default([]) List<TripLineEntity> passengers,
    Position? currentPosition,
    @Default(false) bool isLoading,
    @Default(false) bool isTracking,
    String? error,
  }) = _ActiveTripState;

  factory ActiveTripState.initial() => const ActiveTripState();

  factory ActiveTripState.loading() => const ActiveTripState(isLoading: true);

  factory ActiveTripState.loaded({
    required TripEntity trip,
    required List<TripLineEntity> passengers,
  }) =>
      ActiveTripState(
        trip: trip,
        passengers: passengers,
        isLoading: false,
      );

  factory ActiveTripState.error(String message) => ActiveTripState(
        error: message,
        isLoading: false,
      );
}
