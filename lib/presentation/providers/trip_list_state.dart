import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';

part 'trip_list_state.freezed.dart';

/// حالة قائمة الرحلات
@freezed
class TripListState with _$TripListState {
  const factory TripListState({
    @Default([]) List<TripEntity> trips,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    String? error,
    @Default(false) bool hasMore,
  }) = _TripListState;

  factory TripListState.initial() => const TripListState();

  factory TripListState.loading() => const TripListState(isLoading: true);

  factory TripListState.loaded(List<TripEntity> trips, {bool hasMore = false}) =>
      TripListState(
        trips: trips,
        isLoading: false,
        hasMore: hasMore,
      );

  factory TripListState.refreshing(List<TripEntity> currentTrips) =>
      TripListState(
        trips: currentTrips,
        isRefreshing: true,
      );

  factory TripListState.error(String message, List<TripEntity> currentTrips) =>
      TripListState(
        trips: currentTrips,
        error: message,
        isLoading: false,
      );
}
